Rails.application.routes.draw do
  devise_for :users, :controllers => {
    omniauth_callbacks: "users/omniauth_callbacks",
    registrations: "users/registrations",
    passwords: "users/passwords"
  }

  devise_scope :user do
    get "users/edit_profile" => "users/registrations#edit_profile", as: :edit_user_profile
    get "user/:id" => "users#show", as: :user
    get "users" => "users#index", as: :users
    post "users/:id/add_user_role" => "users#add_user_role", as: :add_user_role
    post "users/:id/remove_user_role" => "users#remove_user_role", as: :remove_user_role
    patch "users/update_profile" => "users/registrations#update_profile", as: :update_user_profile
  end

  resources :courses do
    member do
      get 'edit_structure'
    end
  end

  resources :sections do
    member do
      post 'move_down'
      post 'move_up'
    end
  end

  resources :lessons do
    member do
      post 'move_down'
      post 'move_up'
      post 'attach_task'
      post 'detach_task'
    end
  end

  resources :classrooms do
    member do
      get 'lesson/:lesson_id' => 'classrooms#lesson', as: :lesson
      get 'lesson/:lesson_id/task/:task_id' => 'classrooms#lesson_task', as: :lesson_task
      get 'lesson/:lesson_id/task/:task_id/runs' => 'classrooms#task_runs', as: :task_runs
      get 'users'
      get 'progress'
      post 'enroll'
      post 'lesson/:lesson_id/task/:task_id/solve' => 'classrooms#solve_task', as: :solve_task
    end
  end

  resources :tasks do
    member do
      get 'solve'
      get 'runs'
      post 'do_solve'
    end
  end

  get 'about' => 'pages#about', as: :about

  root 'courses#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
