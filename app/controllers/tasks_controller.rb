class TasksController < ApplicationController
    before_action :require_user_logged_in
    before_action :correct_user, except: [:index, :new, :create]
    def index
        @tasks = current_user.tasks.order(id: :desc).page(params[:page]).per(15)
    end
    
    def show
        @task = Task.find(params[:id])
    end


    def new
        @task = current_user.tasks.build
    end
    
    def create
        @task = current_user.tasks.build(task_params)
        
        if @task.save
            #taskのセーブに成功した場合、下記の文章がユーザーにお知らせとしてWeb上に表示される。
            flash[:success] = "タスクは正常に受理されました"
            #redirect_to @task は、強制的に@taskに飛ばすという意味
            redirect_to @task
        else
            flash.now[:danger] = "タスクが受理されませんでした"
            render :new
        end
    end

    def update
        if @task.update(task_params)
            flash[:success] = "タスクは正常に更新されました"
            redirect_to @task
        else
            flash.now[:danger] = "タスクが更新されませんでした"
            render :edit
        end
    end
    
    def destroy
        @task.destroy
        flash[:success] =  "タスクは削除されました"
        redirect_back(fallback_location: root_path)
    end
    
#privateは、それより下に示されたメソッドはアクションでなく、このクラス内でのみ使用することを明示している。
    private
    #Strong Parameter
    #パラメータを把握し、送信されたデータを精査しようとする（今回はcontentカラムだけが欲しいのでそれ以外はフィルターにかかる）
    def task_params
        #params.require(:task)で、taskモデルのフォームから得られるデータと指定。:permit(:content)で必要なカラムだけを選択
        params.require(:task).permit(:content, :status)
    end
    
    def correct_user
       @task = current_user.tasks.find_by(id: params[:id])
        unless @task
        redirect_to root_url
        end
    end
end