class ContributionsController < ApplicationController
  # GET /contributions
  # GET /contributions.json
  def index
    #debugger
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

    if params[:commit] =~ /Search/
      @page_title = "Search Results for #{params[:search]} in Contributions"
      @candidates = Candidate.search params[:search], params[:page], ordering
    else
      @page_title = "All Contributions"
      @contributions = Contribution.page(params[:page], ordering)
    end

    # construct the composite information of contributions with contributor and candidate names
    @all_contributions = Rails.cache.fetch("all_contribtions") do
      Contribution.get_all_contributions nil
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
