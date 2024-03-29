require 'paging_enumerator'

module PaginatingFind
      
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      class << self
        alias_method :original_find, :find unless method_defined?(:original_find)
        alias_method :find, :paginating_find
      end
    end
  end

  module ClassMethods
    DEFAULT_PAGE_SIZE = 10
    
    # Enhancements to Base find method to support record paging. The :page option
    # is used to specify additional paging options.  The supported :page options are:
    #
    # * <tt>:size</tt>: Number of records in each page of results. Defaults to 1/10
    #                   the total size if total size > 10, otherwise defaults to 1.
    # * <tt>:current</tt>: The current page. Optional, defaults to the first page: 1.
    # * <tt>:first</tt>: The first page. Optional, defaults to the current page.
    # * <tt>:auto</tt>: Automatically load the next page during invocation of #each. Defaults to false.
    # * <tt>:count</tt>: The total record count used to determine the number of pages
    #                    to be loaded. Optional. If not specified, the plugin will
    #                    use the AR::Calculations#count method.
    #
    #
    # If :page is specified, then the enumerable returned will automatically page the 
    # result set for this find operation according to the additional options. Note that
    # if you specify :page, you are getting back and Enumerable, not an Array.
    #
    # You can, however, invoke the #to_a method on the Enumerable. If you’ve got 
    # :auto paging turned off (default), then you’ll get back just the items on 
    # the current page. Otherwise, you’ll get all items on all pages.
    #
    # Heres a sample of how the paging options might be specified:
    #
    # cogs = Cog.find(:all,
    #                 :limit => 3000,
    #                 :page => {:size => 10,
    #                           :first => 1,
    #                           :current => 1, 
    #                           :auto => true})
    #
    def paginating_find(*args)
      options = extract_options_from_args!(args) 
      page_options = options.delete(:page) || (args.delete(:page) ? {} : nil)
      if page_options
        # The :page option was specified, so page the query results
        raise ArgumentError, ":offset option is not supported when paging results" if options[:offset]
        current = page_options[:current] || 1
        first = page_options[:first] || current
        auto = page_options[:auto] || false
        
        # Specify :count to prevent a count query.
        count = page_options.delete(:count)
        count = count(collect_count_options(options)) unless count
        
        # Total size is either count or limit, whichever is less
        limit = options.delete(:limit)
        total_size = limit ? [limit, count].min : count

        # If :size isn't specified, then use the lesser of the total_size
        # and the default page size
        page_size = page_options[:size] || [total_size, DEFAULT_PAGE_SIZE].min
        
        # Cache the :with_scope options so that they can be reused
        # during enumerator callback invocation
        cached_scoped_methods = self.scoped_methods.last
        
        PagingEnumerator.new(page_size, total_size, auto, current, first) do |page|
          args.pop if args.last.is_a?(Hash)
          
          # Set appropriate :offset and :limit options for this page
          options[:offset] = (page - 1) * page_size 
          options[:limit] = (page_size) < total_size ? page_size : total_size
          
          if cached_scoped_methods
            # :with_scope options were specified, so 
            # the with_scope method must be invoked
            self.with_scope(cached_scoped_methods) do
              original_find(*(args << options))
            end
          else
            original_find(*(args << options))
          end
        end
      else
        # The :page option was not specified, so invoke the
        # usual AR::Base#find method
        original_find(*(args << options))
      end
    end
    
    def validate_find_options(options)
      options.assert_valid_keys [:page, :conditions, :include, :joins, :limit, :offset, :order, :select, :readonly, :group]
    end
    
    def collect_count_options(options)
      # Eliminate count options like :group, :order, :limit, :offset.
      # AR::Base#find does not support :having, so I do not support it here either.
      valid_options = [:select, :conditions, :joins, :distinct, :include]
      rtn = {}.merge(options)
      if rtn[:select]
        rtn[:select] = rtn[:select].gsub(/\.\*/, '.id')
      end
      rtn.delete_if { |k, v| !valid_options.include?(k.to_sym) }
      rtn
    end

    def paginating_sql_find(count_query, query, options)
          count_query = sanitize_sql(count_query)
          query = sanitize_sql(query)

          # execute the count query - need to know how many records we're looking at   
          count = count_by_sql(count_query)

          PagingEnumerator.new(options[:page_size], count, false, options[:current], 1) do |page|
              # calculate the right offset values for current page and page_size
              offset = (options[:current].to_i - 1) * options[:page_size]
              limit = options[:page_size] 

              # run the actual query - Note: do not include LIMIT statement in your query          
              find_by_sql(query + " LIMIT #{offset},#{limit}")
          end
    end
    
  end
end