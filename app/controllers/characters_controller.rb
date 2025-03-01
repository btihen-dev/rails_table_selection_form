class CharactersController < ApplicationController
  before_action :set_character, only: %i[ show edit update destroy ]

  # GET /characters or /characters.json
  def index
    # initial query
    # @characters = Character.all

    # fix n+1 query
    # @characters =
    #   Character
    #     .includes(:species)
    #     .includes(character_jobs: { job: :company })
    #     .order(:last_name, :first_name)

    # query with sorting
    column = params[:column]
    direction = params[:direction]

    # base query
    query = Character
            .includes(:species)
            .includes(character_jobs: { job: :company })

    # add sort if direction is given
    query = if direction == 'none' || column.blank?
              query.order('characters.id')
            else
              query.order("#{column} #{direction}")
            end

    # partial match filters
    @company_filter = params[:company_filter]
    query = if @company_filter.present?
              query.joins(character_jobs: { job: :company }).where('companies.company_name ilike ?', "%#{@company_filter}%")
            else
              query
            end


    # execute query
    @characters = query.all
  end

  # GET /characters/1 or /characters/1.json
  def show
  end

  # GET /characters/new
  def new
    @character = Character.new
  end

  # GET /characters/1/edit
  def edit
  end

  # POST /characters or /characters.json
  def create
    @character = Character.new(character_params)

    respond_to do |format|
      if @character.save
        format.html { redirect_to @character, notice: "Character was successfully created." }
        format.json { render :show, status: :created, location: @character }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @character.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /characters/1 or /characters/1.json
  def update
    respond_to do |format|
      if @character.update(character_params)
        format.html { redirect_to @character, notice: "Character was successfully updated." }
        format.json { render :show, status: :ok, location: @character }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @character.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /characters/1 or /characters/1.json
  def destroy
    @character.destroy!

    respond_to do |format|
      format.html { redirect_to characters_path, status: :see_other, notice: "Character was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_character
      @character = Character.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def character_params
      params.expect(character: [ :nick_name, :first_name, :last_name, :given_name, :gender, :species_id ])
    end
end
