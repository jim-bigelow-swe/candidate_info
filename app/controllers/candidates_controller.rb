require 'google_chart'
class CandidatesController < ApplicationController


  # GET /candidates
  # GET /candidates.json
  def index

    if !params[:clear].nil?
      #clear out any sorting or searching parameters in session
      session.except! :sort, :search
      params.except! :sort, :search, :utf8, :clear
      redirect_to params and return
    end

    # find candidates
    sort = params[:sort] || session[:sort]
    case sort
    when 'last'
      ordering, @last_header     = :last, 'hilite'
    when 'party'
      ordering, @party_header    = :party, 'hilite'
    when 'district'
      ordering, @district_header = :district, 'hilite'
    when 'office'
      ordering, @office_header   = :office, 'hilite'
    when 'total'
      ordering, @total_header    = :total, 'hilite'
    end

    if params[:sort] != session[:sort]
      session[:sort] = sort
      flash.keep
      if params[:commit].nil?
        redirect_to :sort => sort  and return
      elsif params[:commit] =~ /Filter/
        redirect_to :elected => params[:elected], :commit => params[:commit], :sort => sort and return
      else
        redirect_to :sort => sort, :commit => params[:commit], :search => params[:search] and return
      end
    end

    #debugger
    if params[:commit] =~ /Filter/ && params[:elected].nil? && !session[:elected].nil?
      # params contains Filter but not elected and session does have elected
      # user unchecked the filter on elected button, removed elected from session
      session.delete(:elected)
      filter = nil
      Rails.cache.delete("contributor_mix")
      Rails.cache.delete('Total Contributions')
      Rails.cache.delete('Contribution Mix')
      Rails.cache.delete('Contributor Counts')

      redirect_to params.except :utf8, :commit and return


    elsif params[:commit] =~ /Filter/ && !params[:elected].nil? && session[:elected].nil?
      # params contains Filter and elected and session doesn't
      # remember the user checked the filter on elected
      session[:elected] = params[:elected]
      filter = params[:elected]
      Rails.cache.delete("contributor_mix")
      Rails.cache.delete('Total Contributions')
      Rails.cache.delete('Contribution Mix')
      Rails.cache.delete('Contributor Counts')

    elsif params[:commit] =~ /Filter/ && params[:elected].nil? && session[:elected].nil?
      # params just has Filter, but not elected and it's not is session either
      # just clean up the RESTful URL
      redirect_to params.except :utf8, :commit and return

    elsif !(params[:commit] =~ /Filter/) && params[:elected].nil? && !session[:elected].nil?
      # params doesn't have filter or elected and session does
      # use the value from session by adding the value to the params list
      params[:elected] = session[:elected]
      redirect_to params and return

    else
      filter = params[:elected]
    end

    if filter.nil?
      @elected_checked = false
    else
      @elected_checked = true
    end


    if params[:commit] =~ /Search/
      @candidates = Candidate.search params[:search], params[:page], ordering, filter
      @contributor_mix = Rails.cache.fetch("contributor_mix") do
        Contribution.find_contrib_mix_per_candidate filter
      end
      # for total_contributions partial
      if ordering == :total
        @total_message = "Total of all contributions where candidate received more than  #{params[:search]}"
      else
        @total_message = %Q{Total of all contributions selected by: "#{ordering} #{params[:search]}"}
      end
      @total_contributions = Contribution.get_candidate_subtotal(ordering, params[:search], filter)
      @contribution_mix = Contribution.get_candidate_contributions_composition_by_selection ordering, params[:search], filter
      @contributor_counts = Contributor.get_candidate_contributor_makeup_by_selection ordering, params[:search], filter

    else
      @candidates = Candidate.page(params[:page], ordering, filter)
      @contributor_mix = Rails.cache.fetch("contributor_mix") do
        Contribution.find_contrib_mix_per_candidate filter
      end

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
    chart =  GoogleChart::PieChart.new('130x75', "", false)
    @contributor_counts.each do |part|
      chart.data part["kind"][0], ((part["number"].to_f/total) * 100).to_i
    end
    chart.show_legend = true
    chart.show_labels = false
    @contributor_chart_url = chart.to_url


    #debugger
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
      format.json { render json: @candidates }
    end
  end

  # GET /candidates/1
  # GET /candidates/1.json
  def show
    @page_title = "Candidate Information"
    #debugger
    @candidate = Candidate.find(params[:id])
    puts "candidates/#{params[:id]}: #{@candidate.last}"
    @contribution_mix = Contribution.get_candidate_total params[:id]
    @contribution_total = @contribution_mix[0]["total"]
    @contributor_number = @contribution_mix[0]["contributors"]
    @company_contributions = @contribution_mix[0]["company"]
    @personal_contributions = @contribution_mix[0]["person"]
    puts "candidates/#{params[:id]}: total #{@contribution_total}"

    @contributions = Contribution.get_candidate_contributions params[:id]

    render :partial => 'list_contributions', :object => @contributions and return if request.xhr?

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @candidate }
    end
  end

  # GET /candidates/new
  # GET /candidates/new.json
  def new
    @candidate = Candidate.new
    @contribution = Contribution.new
    @contributor = Contributor.new


    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @candidate }
    end
  end

  # GET /candidates/1/edit
  def edit
    @candidate = Candidate.find(params[:id])
  end

=begin
  # POST /candidates
  # POST /candidates.json
  def create
    @candidate = Candidate.new(params[:candidate])

    respond_to do |format|
      if @candidate.save
        format.html { redirect_to @candidate, notice: 'Candidate was successfully created.' }
        format.json { render json: @candidate, status: :created, location: @candidate }
      else
        format.html { render action: "new" }
        format.json { render json: @candidate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /candidates/1
  # PUT /candidates/1.json
  def update
    @candidate = Candidate.find(params[:id])

    respond_to do |format|
      if @candidate.update_attributes(params[:candidate])
        format.html { redirect_to @candidate, notice: 'Candidate was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @candidate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /candidates/1
  # DELETE /candidates/1.json
  def destroy
    @candidate = Candidate.find(params[:id])
    @candidate.destroy

    respond_to do |format|
      format.html { redirect_to candidates_url }
      format.json { head :no_content }
    end
  end
=end
end
