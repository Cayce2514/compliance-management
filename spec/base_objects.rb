module BaseObjects
  def create_base_objects
    @creg = FactoryGirl.create(:program, :title => 'Company', :slug => 'COM1', :company => true)
    @reg = FactoryGirl.create(:program, :title => 'Reg 1', :slug => 'REG1', :company => false)
    @ctl = FactoryGirl.create(:control, :title => 'Control 1', :slug => 'REG1-CTL1', :description => 'x', :program => @reg)
    @cycle = FactoryGirl.create(:cycle, :program => @reg, :start_at => '2011-01-01')
    @sec = FactoryGirl.create(:section, :title => 'Section 1', :slug => 'REG1-SEC1', :description => 'x', :program => @reg)
    @sys = FactoryGirl.create(:system, :title => 'System 1', :slug => 'SYS1', :description => 'x', :infrastructure => true)
    @sc = FactoryGirl.create(:system_control, :control => @ctl, :system => @sys, :cycle => @cycle, :state => :green)
    @doc = FactoryGirl.create(:document, :link => 'http://cde.com/', :title => 'Cde')
    @person1 = FactoryGirl.create(:person, :email => 'john@example.com')
  end

  def test_controller_index(assign, objs)
    get 'index'
    response.should be_success
    assigns(assign).should eq(objs)
  end

  def test_controller_create(assign, params)
    post 'create', assign => params
    response.should be_redirect
    result = assigns(assign)
    result.changed?.should be_false
    params.each do |key, value|
      result.send(key).should eq(value)
    end
  end

  def test_controller_update(assign, obj, params)
    put 'update', :id => obj.id, assign => params
    response.should be_redirect
    result = assigns(assign)
    result.should eq(obj)
    result.changed?.should be_false
    params.each do |key, value|
      result.send(key).should eq(value)
    end
  end

  def test_unauth
    login({}, {})
    get 'index'
    response.should be_unauthorized
  end
end
