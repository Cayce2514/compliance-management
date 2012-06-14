require 'spec_helper'
require 'base_objects'

describe ControlsController do
  include BaseObjects

  describe "GET 'show' without authorization" do
    it "fails as guest" do
      login({}, {})
      create_base_objects
      get 'show', :id => @ctl.id
      response.should be_redirect
    end
  end

  context "authorized" do
    before :each do
      login({}, { :role => 'admin' })
      create_base_objects
      @ctl2 = Control.create(:title => 'Control 2', :slug => 'CTL2', :description => 'x', :is_key => true, :fraud_related => false)
      @ctl3 = Control.create(:title => 'Control 3', :slug => 'CTL2-CTL3', :description => 'x', :is_key => true, :fraud_related => false, :parent => @ctl2)
      @sec2 = Section.create(:title => 'Section 2', :slug => 'REG1-SEC2', :description => 'x', :program => @reg)
      @sec3 = Section.create(:title => 'Section 3', :slug => 'REG1-SEC3', :description => 'x', :program => @reg)
      @sec2.controls << @ctl
      @sec2.save
      @sec3.controls << @ctl2
      @sec3.controls << @ctl3
      @sec3.save
    end

    it "shows a control" do
      get 'show', :id => @ctl.id
      response.should be_success
      assigns(:control).should eq(@ctl)
    end

    it "shows controls" do
      get 'index'
      response.should be_success
      assigns(:controls).should eq([@ctl, @ctl2, @ctl3])
    end

    it "edits" do
        get 'edit', :id => @ctl.id
        response.should be_success
        assigns(:control).should eq(@ctl)
    end

    it "updates" do
        put 'update', :id => @ctl.id
        response.should be_success
    end

    it "news" do
        get 'new'
        response.should be_success
        assigns(:control).class.should eq(Control)
    end

    it "creates" do
      request.env["HTTP_REFERER"] = 'back'
      post 'create', :control => { :slug => 'test' }
      response.should redirect_to 'back'
    end
  end
end
