require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe UsersController do

  describe 'Integration Test' do
    before(:each) { get :index }
    subject(:hash) { assigns(:user) }
    subject(:user) { User.instance }

    it 'returns fresh_when hash' do
      expect(hash).to be_a(Hash)
    end

    describe 'hash[:etag]' do
      subject(:etags) { hash[:etag] }

      it 'sets :etag to array' do
        expect(etags).to be_a(Array)
      end

      it 'includes records cache_key' do
        expect(etags).to include(user.cache_key)
      end

      it 'includes all views digest' do
        path = controller.request.path_parameters
        page = ::ActionView::Digestor.cache.keys.first

        expect(page).to match(/#{path['controller']}\/#{path['action']}/)
        expect(etags).to include(::ActionView::Digestor.cache[page])
      end

      it 'includes all asset digests' do
        expect(etags).to include(*(::ActionView::Base.assets_manifest.assets.values))
      end
    end

    describe 'hash[:last_modified]' do
      subject(:last_modified) { hash[:last_modified] }

      it 'sets last_modified to records updated_at' do
        expect(last_modified).to eq(user.updated_at)
      end
    end

  end

end