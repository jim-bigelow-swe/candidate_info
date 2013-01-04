class CandidatesController < ApplicationController
  # GET /candidates
  # GET /candidates.json
  def index
    #@candidates = Candidate.all
    @candidates = Candidate.connection.select_all(
       "SELECT  candidates.last, candidates.elected, candidates.year,
        candidates.id,
        candidates.first,
        candidates.middle,
        candidates.party,
        candidates.district,
        candidates.office,
        SUM(contributions.amount) as contribution_total
        FROM candidates
        INNER JOIN contributions ON contributions.candidate_id = candidates.id
        GROUP BY candidates.last" )

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

    @contribution_totals = Contribution.connection.select_all(
       "SELECT SUM(contributions.amount) as contribution_total
        FROM contributions
        WHERE candidate_id = #{params[:id].to_i}" )
    @contribution_total = @contribution_totals[0]["contribution_total"]

    @contributions = Contribution.connection.select_all(
       "SELECT contributors.last as contributor, contributions.*
        FROM contributions
        INNER JOIN contributors ON contributions.contributor_id = contributors.id
        WHERE contributions.candidate_id = #{params[:id].to_i}" )

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
end
