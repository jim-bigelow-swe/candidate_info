class ContributorsController < ApplicationController
  # GET /contributors
  # GET /contributors.json
  def index
    @page_title = "Contributors Listing"

    #debugger
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
      ordering = :last
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
      #debugger
      @total_message = "Total of all contributions selected by #{params[:search]}"
      @contributors = Contributor.search params[:search], params[:page], ordering

      @total_contributions = Contribution.get_contributor_subtotal ordering, params[:search]
      @contribution_mix = Contribution.get_contributions_composition_by_selection ordering, params[:search]
      @contributor_counts = Contributor.get_contributor_makeup_by_selection ordering, params[:search]
    else
      if session[:elected].nil?
        @total_message = "Total of all contributions"
      else
        @total_message = "Total of all contributions to elected officials"
      end
      @contributors = Contributor.paginate(:page => params[:page], :order => ordering)
      @total_contributions = Contribution.get_total_amount session[:elected]
      @contribution_mix = Contribution.get_contributions_composition session[:elected]
      @contributor_counts = Contributor.get_contributor_makeup session[:elected]
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
