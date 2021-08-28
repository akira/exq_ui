defmodule ExqUIWeb.PaginationComponent do
  use ExqUIWeb, :live_component

  @length 5

  @impl true
  def update(assigns, socket) do
    total_page = ceil(assigns.total / assigns.page_size)
    current_page = Enum.max([Enum.min([assigns.current_page, total_page]), 1])
    start_page = Enum.max([1, current_page - @length])
    end_page = Enum.min([total_page, current_page + @length])

    {:ok,
     assign(socket, %{
       total: assigns.total,
       total_page: total_page,
       current_page: current_page,
       start_page: start_page,
       end_page: end_page
     })}
  end
end
