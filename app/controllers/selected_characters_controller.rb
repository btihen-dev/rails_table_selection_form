class SelectedCharactersController < ApplicationController
  # before_action :set_character, only: %i[ show edit update destroy ]

  # GET /characters or /characters.json
  def index
    sort_column = params['column'] || :id
    sort_direction = params['direction'] || :asc
    # selected_ids = params[:selected_rows]&.map(&:to_i) || []
    selected_ids = params[:selected_rows].to_s.split(',').map(&:to_i).reject(&:zero?)


    # query with sorting
    column = params[:column]
    direction = params[:direction]

    # base query
    query = Character
            .includes(:species)
            .includes(character_jobs: { job: :company })
            .where(id: selected_ids)

    # add sort if direction is given
    query = if direction == 'none' || column.blank?
              query.order('characters.id')
            else
              query.order("#{column} #{direction}")
            end

    # partial match filters
    @first_name_filter = params[:first_name_filter]
    @last_name_filter = params[:last_name_filter]
    @company_filter = params[:company_filter]
    query = query.where('characters.first_name ilike ?', "%#{@first_name_filter}%") if @first_name_filter.present?
    query = query.where('characters.last_name ilike ?', "%#{@last_name_filter}%") if @last_name_filter.present?
    query = if @company_filter.present?
              query.joins(character_jobs: { job: :company }).where('companies.company_name ilike ?', "%#{@company_filter}%")
            else
              query
            end


    # Dropdown selections
    @gender_selection = params[:gender_selection]
    @species_selection = params[:species_selection]
    query = query.where(gender: @gender_selection) if @gender_selection.present?
    query = query.where(species_id: @species_selection) if @species_selection.present?

    @selected_characters = query.all

    respond_to do |format|
      # format.html # Render the selected.html.erb view
      format.html { render :index }
      format.json { render json: @characters }
    end
  end
end
