class ContributionsController < ApplicationController
  # GET /contributions
  # GET /contributions.json
  def index
    #debugger
    @page_title = "All Contributions"
    @contributions =
      Contribution.connection.select_all(
       "SELECT candidates.last as candidate, candidates.elected,
        contributors.last as contributor,
        contributions.*
        FROM contributions
        INNER JOIN candidates ON contributions.candidate_id = candidates.id
        INNER JOIN contributors ON contributors.id = contributions.contributor_id")
    #debugger
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
    id = params[:id].to_i
    data_set =   Contribution.connection.select_all(
       "SELECT candidates.last as candidate, contributors.last as contributor,
        contributions.*
        FROM contributions
        INNER JOIN candidates ON contributions.candidate_id = candidates.id
        INNER JOIN contributors ON contributors.id = contributions.contributor_id
        WHERE contributions.id = #{id} " )
    @contribution = data_set[0] #Contribution.find(params[:id])

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

  # GET /contributions/1/edit
  def edit
    @contribution = Contribution.find(params[:id])
  end

  # POST /contributions
  # POST /contributions.json
  def create

    @contribution_params = params[:contribution]
    attr = @contribution_params.delete :candidates_attributes
    @candidate_params =  attr[:candidates_attributes]
    attr = @contribution_params.delete :contributors_attributes
    @contributor_params = attr[:contributors_attributes]

    @new_candidate = false
    @candidates = Candidate.where(@candidate_params)
    if @candidates.nil? || @candidates.empty?
      @candidate = Candidate.create!(@candidate_params)
      @new_candidate = true
    else
      @candidate = @candidates[0]
    end

    @new_contributor = false
    @contributors = Contributor.where(@contributor_params)
    if @contributors.nil? || @contributors.empty?
      @contributor = Contributor.create!(@contributor_params)
      @new_contributor = true
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

  # PUT /contributions/1
  # PUT /contributions/1.json
  def update
    @contribution = Contribution.find(params[:id])

    respond_to do |format|
      if @contribution.update_attributes(params[:contribution])
        format.html { redirect_to @contribution, notice: 'Contribution was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
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
