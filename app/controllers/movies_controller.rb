class MoviesController < ApplicationController
  load_and_authorize_resource
  before_action :set_movie, only: [:show, :edit, :update, :destroy]
  # before_action :check_admin, only: [:edit, :update, :destroy]

  # GET /movies
  # GET /movies.json
  def index
    # @movies = Movie.all
    @movies = Movie.order(id: :desc).page(params[:page])
    # authorize! :read, Movie
  end

  # GET /movies/1
  # GET /movies/1.json
  def show
    # @sum = 0
    # count = 0
    # @movie.reviews.each do |r|
    #   @sum = @sum + r.rating
    #   count += 1
    # end
    # @avg = @sum/count

    # @avg = @movie.reviews.average(:rating)
    # authorize! :read, Movie
  end

  # GET /movies/new
  def new
    @movie = Movie.new
    # authorize! :create, Movie
  end

  # GET /movies/1/edit
  def edit
    # authorize! :update, Movie
  end

  # POST /movies
  # POST /movies.json
  def create
    @movie = Movie.new(movie_params)

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: 'Movie was successfully created.' }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
      # authorize! :create, Movie
    end
  end

  # PATCH/PUT /movies/1
  # PATCH/PUT /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: 'Movie was successfully updated.' }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
      # authorize! :update, Movie
    end
  end

  # DELETE /movies/1
  # DELETE /movies/1.json
  def destroy
    @movie.destroy
    respond_to do |format|
      format.html { redirect_to movies_url, notice: 'Movie was successfully destroyed.' }
      format.json { head :no_content }
    end
    # authorize! :destroy, Movie
  end

  private
    # def check_admin
    #   # if current_user.admin?
    #   #   true
    #   # end
    #   unless current_user.admin?
    #     redirect_to root_path
    #   end
    # end

    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def movie_params
      params.require(:movie).permit(:title, :desc, :image_url)
    end
end
