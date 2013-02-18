require 'google_chart'
class ContributionsController < ApplicationController
  # GET /contributions
  # GET /contributions.json
  def index
    #debugger

    if !params[:clear].nil?
      #clear out any sorting or searching parameters in session
      session.except! :sort, :search
      params.except! :sort, :search, :utf8, :clear
      redirect_to params and return
    end

    @page_title = "Contributions to Candidates"
    sort = params[:sort] || session[:sort]
    ordering = :id
    case sort
    when 'date'
      ordering, @date_header   = :date, 'hilite'
    when 'amount'
      ordering, @amount_header = :amount, 'hilite'
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

      @contributions = Contribution.search params[:search], params[:page], ordering, filter

      # for total_contributions partial
      @total_message = "Total of all contributions selected by #{params[:search]}"
      @total_contributions = Contribution.get_contribution_subtotal(ordering, params[:search], filter)
      @contribution_mix = Contribution.get_contribution_composition_by_selection ordering, params[:search], filter
      @contributor_counts = Contributor.get_contribution_contributor_makeup_by_selection ordering, params[:search], filter

    else
      @contributions = Contribution.page params[:page], ordering, filter

      # for total_contributions partial
      @total_message = filter.nil? ? "Total of all contributions" : "Total of all contributions to elected officials"

      @total_contributions = Rails.cache.fetch('Total Contributions') do
        Contribution.get_total_amount filter
      end
      @contribution_mix = Rails.cache.fetch('Contribution Mix') do
        Contribution.get_contributions_composition filter
      end
      @contributor_counts = Rails.cache.fetch('Contributor Counts') do
        Contributor.get_contributor_makeup filter
      end
    end

    # add chart of contributor mix
    total = 0
    @contributor_counts.each do |part|
      total += part["number"].to_f
    end
    chart =  GoogleChart::PieChart.new('130x100', "Contributors", false)
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
    chart =  GoogleChart::PieChart.new('80x100', "Contributions", false)
    @contribution_mix.each do |portion|
      chart.data portion["kind"][0], ((portion["number"].to_f/total_number_of_contributions.to_f) * 100).to_i
    end
    chart.show_labels = false
    @contribution_chart_url = chart.to_url

    # construct the composite information of contributions with contributor and candidate names
    @all_contributions = Rails.cache.fetch("all_contributions") do
      Contribution.get_all_contributions filter
    end

    @contribution_data = Hash.new
    @contributions.each do |item|
      contribution_join_data = @all_contributions.select { |data| data["id"].to_i == item.id.to_i }
      @contribution_data[item.id.to_i] = contribution_join_data[0]
    end


    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @contributions }
    end
  end

  # GET /contributions/1
  # GET /contributions/1.json
  def show
    #debugger
    @page_title = "Contribution Information"
    @contribution = Contribution.get_contribution_details params[:id].to_i

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @contribution }
    end

  end

  # GET /contributions/new
  # GET /contributions/new.json
  def new
    @contribution = Contribution.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @contribution }
    end
  end


  # POST /contributions
  # POST /contributions.json
  def create
    Rails.cache.delete("all_contribtions")

    #debugger
    @contribution_params = params[:contribution]
    if @contribution_params.nil?
      render(:nothing => true) and return
    end

    attr = @contribution_params.delete :candidates_attributes
    if attr.nil?
      render(:nothing => true) and return
    end
    @candidate_params =  attr[:candidates_attributes]
    #puts "contributions create: candidate #{@candidate_params}"

    attr = @contribution_params.delete :contributors_attributes
    if attr.nil?
      render(:nothing => true) and return
    end
    @contributor_params = attr[:contributors_attributes]
    puts "contributions create: contributor #{@contributor_params}"

    @new_candidate = false
    @candidates = Candidate.where(@candidate_params)
    if @candidates.nil? || @candidates.empty?
      @candidate = Candidate.create!(@candidate_params)
      @new_candidate = true
      #puts "contributions create: new candidate"
    else
      @candidate = @candidates[0]
    end

    @new_contributor = false
    @contributors = Contributor.where(@contributor_params)
    if @contributors.nil? || @contributors.empty?
      @contributor = Contributor.create!(@contributor_params)
      @new_contributor = true
      #puts "contributions create: new contributor"
    else
      @contributor = @contributors[0]
    end

    @make_new_contribution = false
    if @new_candidate || @new_contributor
      @make_new_contribution = true
    else
      # not a new candidate or contributor, but could be a new contrbituion
      @contribution_params[:candidate_id] = @candidate.id
      @contribution_params[:contributor_id] = @contributor.id
      @contributions =  Contribution.where(@contribution_params)
      if @contributions.nil? || @contributions.empty?
        @make_new_contribution = true
      else
        @contribution = @contributions[0]
      end
    end

    if @make_new_contribution
      @contribution = Contribution.new(@contribution_params)
      @contribution.candidate = @candidate
      @contribution.contributor = @contributor

      #puts "contributions create: new contributio #{@contribution_params}"

      @candidate.total += @contribution.amount
      @candidate.save
      @contributor.total += @contribution.amount
      @contributor.save

      respond_to do |format|
        if @contribution.save
          format.html { redirect_to @contribution, notice: 'Contribution was successfully created.' }
          format.json { render json: @contribution, status: :created, location: @contribution }
        else
          format.html { render action: "new" }
          format.json { render json: @contribution.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { render action: "new" }
        format.json { render json: @contribution.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contributions/1
  # DELETE /contributions/1.json
  def destroy
    @contribution = Contribution.find(params[:id])
    @contribution.destroy

    respond_to do |format|
      format.html { redirect_to contributions_url }
      format.json { head :no_content }
    end
  end
end
