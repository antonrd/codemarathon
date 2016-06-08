Rails.application.routes.draw do
  devise_for :users, skip: :registrations, :controllers => {
    omniauth_callbacks: "omniauth_callbacks",
    passwords: "passwords",
    confirmations: "confirmations",
    sessions: "sessions"
  }

  devise_scope :user do
    resource :registration,
      only: [:new, :create],
      path: 'users',
      controller: 'registrations',
      as: :user_registration
  end

  # TODO: Maybe declare these within the `resources :users` block.
  get "users/edit_profile" => "users#edit_profile", as: :edit_profile
  post "users/update_profile" => "users#update_profile", as: :update_profile
  post "users/:id/add_user_role" => "users#add_user_role", as: :add_user_role
  post "users/:id/remove_user_role" => "users#remove_user_role", as: :remove_user_role

  resources :users, only: [:index, :show] do
    collection do
      get 'inactive'
    end
  end

  resources :courses do
    member do
      get 'edit_structure'
      post 'set_main'
      post 'unset_main'
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
      get 'lesson/:lesson_id/task/:task_id/solution' => 'classrooms#task_solution', as: :task_solution
      get 'lesson/:lesson_id/task/:task_id/task_runs' => 'classrooms#task_runs', as: :task_runs
      get 'lesson/:lesson_id/task/:task_id/student_task_runs' => 'classrooms#student_task_runs', as: :student_task_runs
      get 'users'
      get 'progress'
      get 'student_progress'
      post 'enroll'
      post 'remove_user'
      post 'lesson/:lesson_id/task/:task_id/solve' => 'classrooms#solve_task', as: :solve_task
      post 'update_user_limit'
      post 'add_waiting'
    end
  end

  resources :tasks do
    member do
      get 'solve'
      get 'runs'
      get 'runs_limits'
      get 'solution'
      post 'do_solve'
      post 'update_checker'
      post 'update_runs_limit'
      post 'resubmit_run'
    end

    collection do
      get 'all_runs'
    end
  end

  resources :user_invitations, only: [:index, :create, :update, :destroy]

  get 'about' => 'pages#about', as: :about
  get 'about_codemarathon' => 'pages#about_codemarathon', as: :about_codemarathon

  root 'pages#home'

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
