class ApplicationsController < ApplicationController
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    before_action :find_application_by_token, only: [ :show, :update, :destroy ]
    before_action :application_params, only: [:create, :update]
  
    # Retrieves a list of all applications (GET /applications).
    def index
        @applications = Application.all
        render json: @applications.as_json(methods: :chats_count), status: :ok
    end
    
    # Retrieves a single application by its token (GET /applications/:token).
    def show
      @application = Application.find_by(token: params[:token])
      if @application
        render json: @application, status: :ok
      else
        render json: { error: 'Application not found' }, status: :not_found
      end
    end
  
    # Creates a new application (POST /applications).
    def create
        token = SecureRandom.hex(8)
        @application = Application.new(application_params.merge(token: token))
        if @application.save
            render json: { token: @application.token }, status: :created
        else
            render json: { errors: @application.errors.full_messages }, status: :unprocessable_entity
        end
    end
  
    # Updates an existing application by its token (PATCH/PUT /applications/:token).
    def update
        if @application
          if @application.update(application_params)
            render json: @application, status: :ok
          else
            render json: { errors: @application.errors.full_messages }, status: :unprocessable_entity
          end
        else
          render json: { error: 'Application not found' }, status: :not_found
        end
    end
  
    # Deletes an application by its token (DELETE /applications/:token).
    def destroy
      @application = Application.find_by(token: params[:token])
      if @application
        @application.destroy
        render json: { message: 'Application deleted successfully' }, status: :ok
      else
        render json: { error: 'Application not found' }, status: :not_found
      end
    end
    
    private
    
      def application_params
        params.require(:application).permit(:name)
      end
    
      def record_not_found
        render json: { error: 'Application not found' }, status: :not_found
      end

      def find_application_by_token
          @application = Application.find_by(token: params[:token])
      end
end
  