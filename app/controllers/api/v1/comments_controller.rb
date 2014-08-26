class Api::V1::CommentsController < ApiController
  
  def destroy
    @comment.destroy
    head :no_content
  end
end