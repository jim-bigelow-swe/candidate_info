class CandidatesController < ApplicationController


  # GET /candidates
  # GET /candidates.json
  def index
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


    if params[:commit] =~ /Filter/ && params[:elected].nil? && !session[:elected].nil?
      # user unchecked the filter on elected button, removed elected from session
      session.delete(:elected)
      filter = nil
    elsif params[:commit] =~ /Filter/ && !params[:elected].nil? && session[:elected].nil?
      # remember the user checked the filter on elected
      session[:elected] = params[:elected]
      filter = params[:elected]
    elsif !(params[:commit] =~ /Filter/) && params[:elected].nil? && !session[:elected].nil?
      # use the value from session by adding the value to the params list
      params[:elected] = session[:elected]
      redirect_to params and return
    else
      filter = params[:elected]
    end
    @elected_checked = filter != nil ? true : false

    #debugger
    if params[:commit] =~ /Search/
      @candidates = Candidate.search params[:search], params[:page], ordering, filter
      @contributor_mix = Contribution.find_contrib_mix_per_candidate_range params[:search], params[:page], ordering, filter

      # for total_contributions partial
      @total_message = "Total of all contributions selected by #{params[:search]}"
      @total_contributions = Contribution.get_candidate_subtotal(ordering, params[:search], filter)
      @contribution_mix = Contribution.get_candidate_contributions_composition_by_selection ordering, params[:search], filter
      @contributor_counts = Contributor.get_candidate_contributor_makeup_by_selection ordering, params[:search], filter
    else
      @candidates = Candidate.page(params[:page], ordering, filter)
      @contributor_mix = Contribution.find_contrib_mix_per_candidate params[:page], ordering, filter

      # for total_contributions partial
      @total_message = "Total of all contributions"
      @total_contributions = Contribution.get_total_amount filter
      @contribution_mix = Contribution.get_contributions_composition filter
      @contributor_counts = Contributor.get_contributor_makeup filter
    end

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
    @contribution_total = Contribution.get_candidate_total params[:id]
    @contributions = Contribution.get_candidate_contributions params[:id]

    @company_contributions = 0
    @personal_contributions = 0
    @contributions.each do |contrib|
      @company_contributions += contrib["amount"] if contrib["kind"] == "Company"
      @personal_contributions += contrib["amount"] if contrib["kind"] == "Person"
    end


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
