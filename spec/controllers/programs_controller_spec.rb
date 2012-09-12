require 'spec_helper'
require 'base_objects'
require 'authorized_controller'

describe ProgramsController do
  include BaseObjects

  before :each do
    create_base_objects

    # For use by authorized_controller tests
    @model = Program
    @object = @reg
  end

  context "authorization" do
    it_behaves_like "an authorized create"
    it_behaves_like "an authorized new"
    it_behaves_like "an authorized read", ['show',
                                           'tooltip',
                                           'controls',
                                           'sections',
                                           'section_controls',
                                           'control_sections',
                                           'category_controls']
    it_behaves_like "an authorized update", ['edit', 'update']
    it_behaves_like "an authorized action", ['import'], 'update_program'
  end

  context "show" do
    before :each do
      login({}, { :role => 'superuser' })
      @ctl2 = FactoryGirl.create(:control, :title => 'Control 2', :slug => 'CTL2', :description => 'x', :is_key => true, :fraud_related => false, :program => @creg)
      @ctl3 = FactoryGirl.create(:control, :title => 'Control 3', :slug => 'CTL2-1', :description => 'x', :is_key => true, :fraud_related => false, :parent => @ctl2, :program => @creg)
      @sec2 = FactoryGirl.create(:section, :title => 'Section 2', :slug => 'REG1-SEC2', :description => 'x', :program => @reg)
      @sec3 = FactoryGirl.create(:section, :title => 'Section 3', :slug => 'REG1-SEC3', :description => 'x', :program => @reg)
      @sec2.controls << @ctl
      @sec2.save
      @sec3.controls << @ctl2
      @sec3.controls << @ctl3
      @sec3.save
    end

    it "gets the correct stats" do
      get 'show', :id => @reg.id
      stats = assigns(:stats)
      stats[:sections_count].should eq(3)
      stats[:sections_done_count].should eq(2)
      stats[:sections_undone_count].should eq(1)
      stats[:sections_na_count].should eq(0)
      stats[:controls_count].should eq(3)
      stats[:controls_parented_count].should eq(1)
    end
  end

  context "update" do
    it "should properly validate and update the program"
  end

  context "non-CRUD" do
    before :each do
      login({}, {:role => 'superuser'})
    end

    context "sections" do
      it "should show the right associated sections"
      it "should search properly"
    end

    context "controls" do
      it "should show the right associated sections"
      it "should search properly"
    end


    context "category_controls" do
      it "should display the right categories"
    end

    context "section_controls" do
      it "should do some tests"
    end

    context "control_sections" do
      it "should show the right sections"
    end
  end
end
