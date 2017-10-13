class Api::V1::MessagesController < ApplicationController
before_filter :user_authorized

  def index
    if params[:conversation_id].present?
      conversation = @user.mailbox.conversations.find_by(id: params[:conversation_id])
      conversation.mark_as_read(@user)

      receipts = conversation.receipts_for(@user)
      total_messages = receipts.count

      receipts = receipts.includes(notification: :sender).order("created_at desc").limit(10).offset(params[:off_set])
      @messages = []


      receipts.each do |receipt|
        current_date = DateTime.now.strftime("%B %d, %Y")
        if current_date == receipt.created_at.strftime("%B %d, %Y")
          timestamp = receipt.created_at.strftime("%I:%M%p")
        else
          timestamp = receipt.created_at.strftime("%B %d, %Y %I:%M%p")
        end

        receipt_user = receipt.notification.sender
        user = { id: receipt_user.id, image: receipt_user.image.url, is_owner: receipt_user.id == @user.id ? 1 : 0 }

        @messages.push({ id: receipt.id, body: receipt.message.body, user: user, timestamp: timestamp })
      end

      off_set = params[:off_set].to_i + 10

      @pagination = {
        messages: total_messages,
        off_set: off_set,
        load_more: total_messages > off_set ? 1 : 0,
        url: api_v1_conversation_messages_path(token: params[:token], off_set: off_set, conversation_id: params[:conversation_id])
      }

      render json: { messages: @messages.reverse, pagination: @pagination, status: 200 }, status: 200
    else
      render json: { status: 201 }, status: 200
    end
  end

def create
	receiver = User.includes(:devices).find_by(id: params[:user_id])

	if !params[:conversation_id].present?
		receipt = @user.send_message(receiver, params[:message][:text], "#{@user.name}-#{receiver.name}")
		receipt.update_attribute(:is_read, false)

		devices = receiver.devices.map {|device| device.token}
		if devices.present?
			notification(devices, receipt, receiver)
		end

		render json: {conversation_id: receipt.notification.conversation.id, success: "Message sent", id:receipt.conversation.id,status:200},status: 200
	else
		conversation = @user.mailbox.conversations.find_by(id: params[:conversation_id])

		receipt = @user.reply_to_conversation(conversation, params[:message][:text])
		receipt.update_attribute(:is_read, false)

		  #push notification
		devices = receiver.devices.map { |device| device.token }
		if devices.present?
		    notification(devices, receipt, receiver)
		end

		render json: { success: "Message successfully sent", id: receipt.conversation.id, status: 200 }, status: 200
	    end
	end

end

end