require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/specials_controller'

# Re-raise errors caught by the controller.
class Admin::SpecialsController; def rescue_action(e) raise e end; end

class Admin::SpecialsControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::SpecialsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
