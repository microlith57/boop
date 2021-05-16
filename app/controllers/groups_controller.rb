class GroupsController < ApplicationController
  def index
    query = params[:q]

    @q = Group.ransack query
    @q.sorts = 'name asc' if @q.sorts.empty?
    result = @q.result

    @pagy, @groups = pagy(
      result.includes(:parent),
      items: params[:limit] || Pagy::VARS[:items]
    )
  end

  def show
    @group = Group.find_by! code: params[:id].downcase
  end
end
