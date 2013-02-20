require 'google_chart'
class ContributorsController < ApplicationController
  # GET /contributors
  # GET /contributors.json
  def index
    @page_title = "Contributors Listing"

    #debugger

    if !params[:clear].nil?
      #clear out any sorting or searching parameters in session
      session.except! :sort, :search
      params.except! :sort, :search, :utf8, :clear
      redirect_to params and return
    end

    sort = params[:sort] || session[:sort]
    case sort
    when 'contributions'
      ordering, @contributions_header = :total, 'hilite'
    when 'last'
      ordering, @last_header =  :last, 'hilite'
    when 'city'
      ordering, @city_header =  :city, 'hilite'
    when 'state'
      ordering, @state_header = :state, 'hilite'
    when 'zip'
      ordering, @zip_header =  :zip, 'hilite'
    end
    if ordering.nil?
      ordering = :id
    end


    if params[:sort] != session[:sort]
      session[:sort] = sort
      flash.keep
      if params[:commit].nil?
        redirect_to :sort => sort  and return
      else
        redirect_to :sort => sort, :commit => params[:commit], :search => params[:search] and return
      end
    end

    # checked the elected filter, but do not put in session if not there
    # user must do that on the Candidates page with the "Filter" button
    filter = params[:elected] || session[:elected]
    if params[:elected].nil? and !session[:elected].nil?
      # elected filter comes in the session, correct the RESTful URL
      params[:elected] = session[:elected]
      redirect_to params and return
    end
    if filter.nil?
      @elected_checked = false
    else
      @elected_checked = true
    end


    if params[:commit] =~ /Search/
      #debugger
      if ordering == :total
        @total_message = "Total of all contributions greater than or equal to #{params[:search]}"
      else
        @total_message = %Q{Total of all contributions selected by: "#{ordering} #{params[:search]}"}
      end
      @contributors = Contributor.search params[:search], params[:page], ordering, filter

      @total_contributions = Contribution.get_contributor_subtotal ordering, params[:search], filter
      @contribution_mix = Contribution.get_contributor_contributions_composition_by_selection ordering, params[:search], filter
      @contributor_counts = Contributor.get_contributor_makeup_by_selection ordering, params[:search], filter
    else
      if filter.nil?
        @total_message = "Total of all contributions"
      else
        @total_message = "Total of all contributions to elected officials"
      end
      @contributors = Contributor.page params[:page], ordering, filter
      @total_contributions = Contribution.get_total_amount filter
      @contribution_mix = Contribution.get_contributions_composition filter
      @contributor_counts = Contributor.get_contributor_makeup filter
    end


    # add chart of contributor mix
    total = 0
    @contributor_counts.each do |part|
      total += part["number"].to_f
    end
    chart =  GoogleChart::PieChart.new('130x75', "", false)
    @contributor_counts.each do |part|
      chart.data part["kind"][0], ((part["number"].to_f/total) * 100).to_i
    end
    chart.show_legend = true
    chart.show_labels = false
    @contributor_chart_url = chart.to_url

    total_number_of_contributions = 0
    @contribution_mix.each do |portion|
      total_number_of_contributions += portion["number"].to_f
    end
    chart =  GoogleChart::PieChart.new('75x75', "", false)
    @contribution_mix.each do |portion|
      chart.data portion["kind"][0], ((portion["number"].to_f/total_number_of_contributions.to_f) * 100).to_i
    end
    chart.show_labels = false
    @contribution_chart_url = chart.to_url


    chart =  GoogleChart::PieChart.new('75x75', "", false)
    @contribution_mix.each do |portion|
      chart.data portion["kind"][0], ((portion["total"].to_f/@total_contributions.to_f) * 100).to_i
    end
    chart.show_labels = false
    chart.show_legend = false
    @contribution_percent_chart_url = chart.to_url

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @contributors }
    end
  end

  # GET /contributors/1
  # GET /contributors/1.json
  def show
    @page_title = "Contributor Information"
    @contributor = Contributor.find(params[:id])
    @contribution_total = Contribution.get_contributor_total params[:id]
    @contributions = Contribution.get_contributor_contributions params[:id]

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @contributor }
    end
  end

  # GET /contributors/new
  # GET /contributors/new.json
  def new
    @contributor = Contributor.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @contributor }
    end
  end

  # GET /contributors/1/edit
  def edit
    @contributor = Contributor.find(params[:id])
  end

=begin
  # POST /contributors
  # POST /contributors.json
  def create
    @contributor = Contributor.new(params[:contributor])

    respond_to do |format|
      if @contributor.save
        format.html { redirect_to @contributor, notice: 'Contributor was successfully created.' }
        format.json { render json: @contributor, status: :created, location: @contributor }
      else
        format.html { render action: "new" }
        format.json { render json: @contributor.errors, status: :unprocessable_entity }
      end
    end
  end
=end

  # PUT /contributors/1
  # PUT /contributors/1.json
  def update
    #debugger
    @contributor = Contributor.find(params[:id])

    respond_to do |format|
      if @contributor.update_attributes(params[:contributor])
        format.html { redirect_to @contributor, notice: 'Contributor was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @contributor.errors, status: :unprocessable_entity }
      end
    end
  end
=begin
  # DELETE /contributors/1
  # DELETE /contributors/1.json
  def destroy
    @contributor = Contributor.find(params[:id])
    @contributor.destroy

    respond_to do |format|
      format.html { redirect_to contributors_url }
      format.json { head :no_content }
    end
  end
=end
end
