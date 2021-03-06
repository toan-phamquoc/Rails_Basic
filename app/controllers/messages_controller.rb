class MessagesController < ApplicationController
before_action :authenticate_user!
  def index
  end

  def show
    @message = Message.find(params[:id])
    #puts @message.read.inspect
    #puts @message.receiver_id.inspect
    if @message.read == false && @message.receiver_id == current_user.id
      @message.update(read: true, readed_at: Time.zone.now)
      NotifierMailer.read_message(@message).deliver
    end
  end

  def getmess
    id = params[:id]
    @message = Message.find(id.to_i)
    #puts @message.inspect
    respond_to do |format|
    format.html
    format.json {render json: @message}
  end
  end

  def new
    # @friends = User.where.not(id: current_user.id)
    @users = User.where.not(id: current_user.id)

    @temp = Tablefriend.where(id_acc: current_user.id)
    friendArr = []
    @temp.each do |u|
      friendArr.push(u.id_friend)
    end

    @temp = Tablefriend.where(id_friend: current_user.id)
    @temp.each do |u|
      friendArr.push(u.id_acc)
    end

    @friends = User.where('id in (?)', friendArr)
    @message = Message.new
  end

  def create
    # @message = Message.new(message_params)
    # @message.user_sender = current_user
    # if @message.save
    #   flash[:notice] = "Message was successfully sent"
    #   NotifierMailer.new_message(@message).deliver
    #   redirect_to messages_sent_path
    # else render 'new'
    # end
    params[:message][:receiver_id].each do |id|
      if !id.empty?
        @message = Message.new
        @message.sender_id = current_user.id
        @message.subject = params[:message][:subject]
        @message.body = params[:message][:body]
        @message.receiver_id = id
        if @message.save
          flash[:notice] = "Message was successfully sent"
          NotifierMailer.new_message(@message).deliver
        else
          render 'new'
        end
      end
    end
    redirect_to messages_sent_path

  end

  def inbox
    # NotifierMailer.welcome(current_user).deliver
    @temp = BlockFriend.where(id_acc: current_user.id)
    b_friendArr = []
    b_friendArr.push(0)
    @temp.each do |u|
      b_friendArr.push(u.id_friend)
    end

    @messages = Message.where('sender_id not in (?) and receiver_id = (?)',b_friendArr,current_user.id).all.order('created_at DESC')
    @count_unread_inbox = Message.where(receiver_id: current_user.id, read: false).where('sender_id not in (?)',b_friendArr).count
    @count_unread_sent = Message.where(sender_id: current_user.id, read: false).count
    @active = :inbox
  end

  def sent
    @messages = Message.where(sender_id: current_user.id).all.order('created_at DESC')
    @count_unread_inbox = Message.where(receiver_id: current_user.id, read: false).count
    @count_unread_sent = Message.where(sender_id: current_user.id, read: false).count
    @active = :sent
  end

  def trash
    @active = :trash
  end

  def important
    @active = :important
  end

  def drafts
    @active = :drafts
  end

  private
    # def message_params
    #   params.require(:message).permit(:receiver_ids [], :body, :subject)
    # end
end
