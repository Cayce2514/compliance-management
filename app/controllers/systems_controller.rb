# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# HandleSystems
class SystemsController < ApplicationController
  include ApplicationHelper

  access_control :acl do
    allow :superuser, :admin, :analyst
  end

  layout 'dashboard'

  def edit
    @system = System.find(params[:id])

    render :layout => nil
  end

  def show
    @system = System.find(params[:id])
  end

  def tooltip
    @system = System.find(params[:id])
    render :layout => '_tooltip', :locals => { :system => @system }
  end

  def new
    @system = System.new(system_params)

    render :layout => nil
  end

  def create
    @system = System.new(system_params)

    respond_to do |format|
      if @system.save
        flash[:notice] = "Successfully created a new system."
        format.json do
          render :json => @system.as_json(:root => nil), :location => flow_system_path(@system)
        end
        format.html { redirect_to flow_system_path(@system) }
      else
        flash[:error] = "There was an error creating the system"
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def update
    @system = System.find(params[:id])

    respond_to do |format|
      if @system.authored_update(current_user, system_params)
        flash[:notice] = "Successfully updated the system."
        format.json do
          render :json => @system.as_json(:root => nil)
        end
        format.html { redirect_to flow_system_path(@system) }
      else
        flash[:error] = "There was an error updating the system"
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def destroy
    @system = System.find(params[:id])

    respond_to do |format|
      if @system.destroy
        flash[:notice] = "System deleted"
        format.html { ajax_refresh }
      else
        flash[:error] = "Failed to delete system"
        format.html { ajax_refresh }
      end
    end
  end

  def index
    @systems = System.all
  end

  def subsystems_edit
    @system = System.find(params[:id])
    @systems = System.where({})
    render :layout => nil
  end

  def subsystems_update
    @system = System.find(params[:id])

    new_system_systems = []

    if params[:items]
      params[:items].each do |_, item|
        # Do whatever is needed with item-forms
        system_system = @system.sub_system_systems.where(:child_id => item[:id]).first
        if !system_system
          child = System.find(item[:id])
          system_system = @system.sub_system_systems.new(:child => child)
        end
        new_system_systems.push(system_system)
      end
    end

    @system.sub_system_systems = new_system_systems

    respond_to do |format|
      if @system.save
        format.json do
          render :json => @system.sub_systems.all.map { |s| s.as_json(:root => nil) }
        end
        format.html
      else
        flash[:error] = "Could not update subsystems"
        format.html { render :layout => nil }
      end
    end
  end

  def controls_edit
    @system = System.find(params[:id])
    @controls = Control.where({})
    render :layout => nil
  end

  def controls_update
    @system = System.find(params[:id])

    new_system_controls = []

    if params[:items]
      params[:items].each do |_, item|
        # Do whatever is needed with item-forms
        system_control = @system.system_controls.where(:control_id => item[:id]).first
        if !system_control
          control = Control.find(item[:id])
          system_control = @system.system_controls.new(:control => control)
        end
        new_system_controls.push(system_control)
      end
    end

    @system.system_controls = new_system_controls

    respond_to do |format|
      if @system.save
        format.json do
          render :json => @system.controls.all.map { |c| c.as_json(:root => nil) }
        end
        format.html
      else
        flash[:error] = "Could not update subsystems"
        format.html { render :layout => nil }
      end
    end
  end

  private

    def system_params
      system_params = params[:system] || {}
      %w(type).each do |field|
        value = system_params.delete(field + '_id')
        if value.present?
          system_params[field] = Option.find(value)
        end
      end

      # Fixup legacy boolean
      if system_params[:type]
        system_params[:infrastructure] = system_params[:type].title == 'Infrastructure'
      else
        system_params[:infrastructure] = false
      end

      system_params
    end
end
