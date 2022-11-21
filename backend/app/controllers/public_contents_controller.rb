class PublicContentsController < ApplicationController
  before_action :set_public_content, only: %i[ show edit update destroy ]

  # GET /public_contents or /public_contents.json
  def index
    @public_contents = PublicContent.all
  end

  # GET /public_contents/1 or /public_contents/1.json
  def show
  end

  # GET /public_contents/new
  def new
    @public_content = PublicContent.new
  end

  # GET /public_contents/1/edit
  def edit
  end

  # POST /public_contents or /public_contents.json
  def create
    @public_content = PublicContent.new(public_content_params)

    respond_to do |format|
      if @public_content.save
        format.html { redirect_to public_content_url(@public_content), notice: "Public content was successfully created." }
        format.json { render :show, status: :created, location: @public_content }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @public_content.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /public_contents/1 or /public_contents/1.json
  def update
    respond_to do |format|
      if @public_content.update(public_content_params)
        format.html { redirect_to public_content_url(@public_content), notice: "Public content was successfully updated." }
        format.json { render :show, status: :ok, location: @public_content }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @public_content.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /public_contents/1 or /public_contents/1.json
  def destroy
    @public_content.destroy

    respond_to do |format|
      format.html { redirect_to public_contents_url, notice: "Public content was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_public_content
      @public_content = PublicContent.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def public_content_params
      params.require(:public_content).permit(:name)
    end
end
