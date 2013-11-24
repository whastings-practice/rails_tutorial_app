module RailsTutorialApp
  module Spec
    module MicropostUtils

      def get_test_micropost(user = get_test_user, options = {})
        options[:user] = user
        FactoryGirl.create(:micropost, options)
      end

    end
  end
end
