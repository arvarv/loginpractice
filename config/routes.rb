Rails.application.routes.draw do
  devise_for :users, path: 'v1', controllers: { registrations: "api/v1/registrations", sessions: "api/v1/sesions"}

  root 'welcome#index'

  namespace :api, path: '' do
    namespace :v1 do


      devise_scope :user do
        post 'register'                                               => 'registrations#create'
        post 'sign-in'                                                => 'sessions#create'
        post 'social'                                                 => 'sessions#social'
      end

      resources :users, path: :accounts, only: [:update] do
        collection{
          put :location
          put 'status'
          resources :tasks, only: [:create, :update]
        }
      end

      resources :users, except: [:new, :edit, :update] do
        put 'upload-image'                                            => 'users#upload'
        post 'forgot'
        get 'contacts'

        resources :tasks, only: [:index]
      end
    end

    # namespace :v2 do
    #   resources :users, only: [:index]
    # end
  end
end
# 334a078c76537a09e3fc3423133a0a142c651beb