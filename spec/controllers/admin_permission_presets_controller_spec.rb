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

describe Admin::PermissionPresetsController do

  before :each do
    @adam = PersonaFactory.create :adam
  end

  # This should return the minimal set of attributes required to create a valid
  # PermissionPreset. As you add validations to PermissionPreset, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {name: "Nobody", view: false, download: false, edit: false, manage:false}
  end
  
  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # PermissionPresetsController. Be sure to keep this updated too.
  def valid_session
    {user_id: @adam.id}
  end

  describe "GET index" do
    it "assigns all permission_presets as @permission_presets" do
      permission_preset = PermissionPreset.create! valid_attributes
      get :index, {}, valid_session
      assigns(:permission_presets).should eq([permission_preset])
    end
  end

  describe "GET show" do
    it "assigns the requested permission_preset as @permission_preset" do
      permission_preset = PermissionPreset.create! valid_attributes
      get :show, {:id => permission_preset.to_param}, valid_session
      assigns(:permission_preset).should eq(permission_preset)
    end
  end

  describe "GET new" do
    it "assigns a new permission_preset as @permission_preset" do
      get :new, {}, valid_session
      assigns(:permission_preset).should be_a_new(PermissionPreset)
    end
  end

  describe "GET edit" do
    it "assigns the requested permission_preset as @permission_preset" do
      permission_preset = PermissionPreset.create! valid_attributes
      get :edit, {:id => permission_preset.to_param}, valid_session
      assigns(:permission_preset).should eq(permission_preset)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new PermissionPreset" do
        expect {
          post :create, {:permission_preset => valid_attributes}, valid_session
        }.to change(PermissionPreset, :count).by(1)
      end

      it "assigns a newly created permission_preset as @permission_preset" do
        post :create, {:permission_preset => valid_attributes}, valid_session
        assigns(:permission_preset).should be_a(PermissionPreset)
        assigns(:permission_preset).should be_persisted
      end

      it "redirects to the created permission_preset" do
        post :create, {:permission_preset => valid_attributes}, valid_session
        response.should redirect_to(admin_permission_preset_url PermissionPreset.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved permission_preset as @permission_preset" do
        # Trigger the behavior that occurs when invalid params are submitted
        PermissionPreset.any_instance.stub(:save).and_return(false)
        post :create, {:permission_preset => {}}, valid_session
        assigns(:permission_preset).should be_a_new(PermissionPreset)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        PermissionPreset.any_instance.stub(:save).and_return(false)
        post :create, {:permission_preset => {}}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested permission_preset" do
        permission_preset = PermissionPreset.create! valid_attributes
        # Assuming there are no other permission_presets in the database, this
        # specifies that the PermissionPreset created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        PermissionPreset.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => permission_preset.to_param, :permission_preset => {'these' => 'params'}}, valid_session
      end

      it "assigns the requested permission_preset as @permission_preset" do
        permission_preset = PermissionPreset.create! valid_attributes
        put :update, {:id => permission_preset.to_param, :permission_preset => valid_attributes}, valid_session
        assigns(:permission_preset).should eq(permission_preset)
      end

      it "redirects to the permission_preset" do
        permission_preset = PermissionPreset.create! valid_attributes
        put :update, {:id => permission_preset.to_param, :permission_preset => valid_attributes}, valid_session
        response.should redirect_to(admin_permission_preset_url(permission_preset))
      end
    end

    describe "with invalid params" do
      it "assigns the permission_preset as @permission_preset" do
        permission_preset = PermissionPreset.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        PermissionPreset.any_instance.stub(:save).and_return(false)
        put :update, {:id => permission_preset.to_param, :permission_preset => {}}, valid_session
        assigns(:permission_preset).should eq(permission_preset)
      end

      it "re-renders the 'edit' template" do
        permission_preset = PermissionPreset.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        PermissionPreset.any_instance.stub(:save).and_return(false)
        put :update, {:id => permission_preset.to_param, :permission_preset => {}}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested permission_preset" do
      permission_preset = PermissionPreset.create! valid_attributes
      expect {
        delete :destroy, {:id => permission_preset.to_param}, valid_session
      }.to change(PermissionPreset, :count).by(-1)
    end

    it "redirects to the permission_presets list" do
      permission_preset = PermissionPreset.create! valid_attributes
      delete :destroy, {:id => permission_preset.to_param}, valid_session
      response.should redirect_to(admin_permission_presets_url)
    end
  end

end
