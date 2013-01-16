require 'spec_helper'

describe CollaboratorsHelper do
  describe "#delete_collaborator_box" do
    it "should return a link" do
      collaborator = Factory(:user_list_link)
      helper.delete_collaborator_box(collaborator).should have_tag('a')
    end
  end
end