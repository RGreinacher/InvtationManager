class GuestsController < ApplicationController
  before_action :set_guest, only: [:show, :edit, :update, :destroy]

  # GET /guests
  def index
    @participating_guests = Guest.where(participating: 3).order(:name)
    @not_sure_guests = Guest.where(participating: 2).order(:name)
    @turned_down_guests = Guest.where(participating: 1).order(:name)
    @undecided_guests = Guest.where(participating: 0).order(:name)
  end

  # GET /guests/1
  def show
  end

  # GET /guests/new
  def new
    @guest = Guest.new
  end

  # GET /guests/1/edit
  def edit
    @present = Present.new
    @presents = Present.all.order(:description)
  end

  # POST /guests
  def create
    @guest = Guest.new(guest_params)
    @guest.participating = :undecided
    @guest.companions = 0
    @guest.emails_sent = 0
    @guest.token = SecureRandom.hex

    respond_to do |format|
      if @guest.save
        format.html { redirect_to @guest, notice: t('flashes.messages.create-success') }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /guests/1
  def update
    respond_to do |format|
      if @guest.update(guest_params)
        format.html { redirect_to edit_guest_path(@guest), notice: t('flashes.messages.update-success') }
      else
        format.html { render :edit }
      end
    end
  end

  # PATCH /guests/enqueue/
  def enqueue
    if params.has_key? :enqueue_all_guests
      Guest.all.each do |guest|
        guest.queued = params[:enqueue_all_guests]
        guest.save!
      end
    else
      guest = Guest.find(params[:enqueue_guest].to_i)
      guest.queued ^= true
      guest.save!
    end

    render json: { success: true }, status: 200
  end

  # DELETE /guests/1
  def destroy
    @guest.destroy
    respond_to do |format|
      format.html { redirect_to guests_url, notice: t('flashes.messages.delete-success') }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_guest
      @guest = Guest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def guest_params
      params.require(:guest).permit(
        :name,
        :notice,
        :email,
        :participating,
        :companions,
        :emails_sent,
        :salutation,
        :enqueue_all_guests,
        :enqueue_guest
      )
    end
end
