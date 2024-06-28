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
      if @application
        render json: @application, status: :ok
      else
        render json: { error: 'Application not found' }, status: :not_found
      end
    end
  
    # Creates a new application (POST /applications).
    def create
      token = SecureRandom.uuid
      CreateAppJob.perform_async(token, application_params[:name])
      render json: { token: token }, status: :created
    end
  
    # Updates an existing application by its token (PATCH/PUT /applications/:token).
    def update
      UpdateAppJob.perform_async(params[:token], params[:name])
      render json: { token: params[:token] }, status: :created
    end
  
    # Deletes an application by its token (DELETE /applications/:token).
    def destroy
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
  