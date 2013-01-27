class ContributorsController < ApplicationController
  # GET /contributors
  # GET /contributors.json
  def index
    @page_title = "Contributors Listing"

    sort = params[:sort] || session[:sort]
    case sort
    when 'last'
      ordering, @last_header =  :last, 'hilite'
    when 'city'
      ordering, @city_header =  :city, 'hilite'
    when 'state'
      ordering, @state_header = :state, 'hilite'
    when 'zip'
      ordering, @zip_header =  :zip, 'hilite'
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
      @contributors = Contributor.search params[:search], params[:page], ordering
    else
      @contributors = Contributor.paginate(:page => params[:page], :order => ordering)
    end

    @total_contributions = 0
    @contribution_amounts = Hash.new
    if params[:commit] =~ /Search/
      @total_message = "Total of all contributions selected by #{params[:search]}"
     contributions =
      Contribution.connection.select_all(
     %Q{SELECT contributor_id, contributions.amount FROM contributions
        INNER JOIN contributors ON contributions.contributor_id = contributors.id
        WHERE contributors.#{ordering.to_s} LIKE '%#{params[:search]}%'} )

    else
      @total_message = "Total of all contributions"
     contributions = Contribution.connection.select_all("SELECT * from contributions")
    end

    #debugger
    contributions.each do |contribution|
      id = contribution["contributor_id"].to_s
      if @contribution_amounts[id].nil?
        @contribution_amounts[id] = contribution["amount"].to_f
      else
        @contribution_amounts[id] += contribution["amount"].to_f
      end
      @total_contributions += contribution["amount"].to_f
    end


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

    @contribution_totals = Contribution.connection.select_all(
       "SELECT SUM(contributions.amount) as contribution_total
        FROM contributions
        WHERE contributor_id = #{params[:id].to_i}" )
    @contribution_total = @contribution_totals[0]["contribution_total"]

    @contributions = Contribution.connection.select_all(
       "SELECT candidates.last as candidate, contributions.*
        FROM contributions
        INNER JOIN candidates ON contributions.candidate_id = candidates.id
        WHERE contributions.contributor_id = #{params[:id].to_i}" )



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
