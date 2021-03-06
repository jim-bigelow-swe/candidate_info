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

describe ContributionsController do

  # This should return the minimal set of attributes required to create a valid
  # Contribution. As you add validations to Contribution, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { :date              => "2010-09-17",
      :amount            => "250.00",
      :contribution_type => "C",
      :candidates_attributes => {
        :elected  => false,
        :year     => "2011-11-06",
        :last     => "Eskridge",
        :suffix   => "",
        :first    => "George",
        :middle   => "E.",
        :party    => "REP",
        :district => "1",
        :office   => "STATE REP., POSITION B"
      },
      :contributors_attributes => {
        :last    => "AGRA PAC",
        :suffix  => "",
        :first   => "",
        :middle  => "",
        :mailing => "PO BOX 4848",
        :city    => "POCATELLO",
        :state   => "ID",
        :zip     => "83205"
      }
    }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ContributionsController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all contributions as @contributions" do
      contribution = Contribution.create! valid_attributes
      get :index, {}, valid_session
      assigns(:contributions).should eq([contribution])
    end
  end

  describe "GET show" do
    it "assigns the requested contribution as @contribution" do
      contribution = Contribution.create! valid_attributes
      get :show, {:id => contribution.to_param}, valid_session
      assigns(:contribution).should eq(contribution)
    end
  end

  describe "GET new" do
    it "assigns a new contribution as @contribution" do
      get :new, {}, valid_session
      assigns(:contribution).should be_a_new(Contribution)
    end
  end

  describe "GET edit" do
    it "assigns the requested contribution as @contribution" do
      contribution = Contribution.create! valid_attributes
      get :edit, {:id => contribution.to_param}, valid_session
      assigns(:contribution).should eq(contribution)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Contribution" do
        expect {
          debugger
          post :create, {:contribution => valid_attributes}, valid_session
        }.to change(Contribution, :count).by(1)
      end

      it "assigns a newly created contribution as @contribution" do
        post :create, {:contribution => valid_attributes}, valid_session
        assigns(:contribution).should be_a(Contribution)
        assigns(:contribution).should be_persisted
      end

      it "redirects to the created contribution" do
        post :create, {:contribution => valid_attributes}, valid_session
        response.should redirect_to(Contribution.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved contribution as @contribution" do
        # Trigger the behavior that occurs when invalid params are submitted
        Contribution.any_instance.stub(:save).and_return(false)
        post :create, {:contribution => { "candidate_id" => "invalid value" }}, valid_session
        assigns(:contribution).should be_a_new(Contribution)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Contribution.any_instance.stub(:save).and_return(false)
        post :create, {:contribution => { "candidate_id" => "invalid value" }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested contribution" do
        contribution = Contribution.create! valid_attributes
        # Assuming there are no other contributions in the database, this
        # specifies that the Contribution created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Contribution.any_instance.should_receive(:update_attributes).with({ "candidate_id" => "" })
        put :update, {:id => contribution.to_param, :contribution => { "candidate_id" => "" }}, valid_session
      end

      it "assigns the requested contribution as @contribution" do
        contribution = Contribution.create! valid_attributes
        put :update, {:id => contribution.to_param, :contribution => valid_attributes}, valid_session
        assigns(:contribution).should eq(contribution)
      end

      it "redirects to the contribution" do
        contribution = Contribution.create! valid_attributes
        put :update, {:id => contribution.to_param, :contribution => valid_attributes}, valid_session
        response.should redirect_to(contribution)
      end
    end

    describe "with invalid params" do
      it "assigns the contribution as @contribution" do
        contribution = Contribution.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Contribution.any_instance.stub(:save).and_return(false)
        put :update, {:id => contribution.to_param, :contribution => { "candidate_id" => "invalid value" }}, valid_session
        assigns(:contribution).should eq(contribution)
      end

      it "re-renders the 'edit' template" do
        contribution = Contribution.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Contribution.any_instance.stub(:save).and_return(false)
        put :update, {:id => contribution.to_param, :contribution => { "candidate_id" => "invalid value" }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested contribution" do
      contribution = Contribution.create! valid_attributes
      expect {
        delete :destroy, {:id => contribution.to_param}, valid_session
      }.to change(Contribution, :count).by(-1)
    end

    it "redirects to the contributions list" do
      contribution = Contribution.create! valid_attributes
      delete :destroy, {:id => contribution.to_param}, valid_session
      response.should redirect_to(contributions_url)
    end
  end

end
