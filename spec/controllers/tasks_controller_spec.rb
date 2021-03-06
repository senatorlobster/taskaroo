require 'spec_helper'

describe TasksController do

  describe "#index" do

    context "while signed out" do

      it "redirects to welcome page" do
        get :index
        response.should redirect_to root_path
        flash[:alert].should eql "You need to be signed in to view Tasks."
      end
    end

    context "while signed in" do

      before(:each) do
        @user = users(:user_1)
        sign_in @user
      end

      it "returns a page" do
        get :index
        response.should be_success
      end

      it "contains all of the user's tasks" do
        get :index
        assigns["tasks"].should =~ lists(:list_1).tasks
      end

      # esdy: I think I can get rid of this test.
      it "doesn't show other users' tasks" do
        new_user = User.create(uid: '2468', provider: 'twitter', nickname: 'plizzle')
        sign_in new_user

        get :index
        assigns["tasks"].count.should eql 0
      end
    end
  end

  describe "#new" do

    context "while signed out" do

      it "redirects to welcome page" do
        get :new
        response.should redirect_to root_path
        flash[:alert].should eql "You need to be signed in to create Tasks."
      end
    end

    context "while signed in" do

      before(:each) do
        @user = users(:user_1)
        sign_in @user
      end

      it "returns a page" do
        get :new
        response.should be_success
      end

      it "has a new task as a variable" do

        get :new
        assigns["task"].should_not be_valid
        assigns["task"].should_not be_nil
      end

      it "contains all of the user's lists" do
        get :new
        assigns["lists"].should =~ @user.lists
      end
    end
  end

  describe "#create" do

    context "while signed out" do

      it "redirects to welcome page" do
        post :create
        response.should redirect_to root_path
        flash[:alert].should eql "You need to sign in to create Tasks."
      end
    end

    context "while signed in" do

      before(:each) do
        @user = users(:user_1)
        sign_in @user
      end

      it "creates an object and redirects to the Tasks index page if fed a valid task" do
        
        list = lists(:list_1)
        post :create, task: { description: "here is a new task", list_id: list }
        task = Task.find_by description: "here is a new task"

        task.should be_valid
        task.list.should eql list
        response.should redirect_to tasks_path
        flash[:notice].should eql "Task saved."
      end

      it "renders the 'new' template and has errors if fed an invalid object" do
        
        count = Task.count
        post :create, task: { description: "" }

        count.should eql Task.count
        assigns["task"].should_not be_nil
        assigns["task"].errors.should_not be_nil
        assigns["task"].errors["description"].first.should eql "can't be blank"
        response.should render_template("tasks/new")
        flash[:error].should eql "There was an error saving the task. Please try again."
      end
    end
  end

  describe "#edit" do

    before(:each) do
      @user = users(:user_1)
      @list = @user.lists.first
      @task = @list.tasks.first
    end

    context "while signed out" do

      it "redirects to welcome page" do

        get :edit, id: @task
        response.should redirect_to root_path
        flash[:alert].should eql "Sign in to edit Tasks."
      end
    end

    context "while signed in" do

      before(:each) do
        sign_in @user
      end

      it "returns a page" do

        get :edit, id: @task
        response.should be_success
      end

      it "has the right task as a variable" do

        get :edit, id: @task
        assigns["task"].should eql @task
      end

      it "redirects to Tasks index page if I request a task that's not mine" do

        user2 = users(:user_2)
        list2 = user2.lists.first
        task2 = Task.create( description: "Go to the store", list: list2 )

        get :edit, id: task2

        response.should redirect_to tasks_path
        flash[:error].should eql "Task not found."
      end
    end
  end

  describe "#update" do

    before(:each) do
      @user = users(:user_1)
      @list = lists(:list_1)
      @task = tasks(:task1_list1)
    end

    context "while signed out" do

      it "redirects to welcome page" do
        put :update, id: @task
        response.should redirect_to root_path
        flash[:alert].should eql "Sign in to edit Tasks."
      end
    end

    context "while signed in" do

      before(:each) do
        sign_in @user
      end

      it "updates the object and redirects to the Tasks index page if fed a valid task" do
        
        count = Task.count

        put :update, id: @task, task: { description: "Buy tickets to Chiloe." }
        task = Task.find @task.id

        task.description.should eql "Buy tickets to Chiloe."
        count.should eql Task.count
        task.should be_valid
        task.list.user.should eql @user
        response.should redirect_to tasks_path
        flash[:notice].should eql "Task saved."
      end

      it "renders the 'edit' template and has errors if fed an invalid object" do
        
        count = Task.count

        put :update, id: @task, task: { description: "" }
        task = Task.find @task.id

        task.description.should eql "Email Damon."
        count.should eql Task.count
        assigns["task"].should_not be_nil
        assigns["task"].errors.should_not be_nil
        assigns["task"].errors["description"].first.should eql "can't be blank"
        response.should render_template("tasks/edit")
        flash[:error].should eql "There was an error saving the task. Please try again."
      end
    end
  end

end
