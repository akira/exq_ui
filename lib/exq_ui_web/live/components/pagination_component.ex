defmodule ExqUIWeb.PaginationComponent do
  use ExqUIWeb, :live_component

  @length 5

  @impl true
  def update(assigns, socket) do
    total_page = ceil(assigns.total / assigns.page_size)
    start_page = Enum.max([1, assigns.current_page - @length])
    end_page = Enum.min([total_page, assigns.current_page + @length])

    {:ok,
     assign(socket, %{
       total: assigns.total,
       total_page: total_page,
       current_page: assigns.current_page,
       start_page: start_page,
       end_page: end_page
     })}
  end
end
