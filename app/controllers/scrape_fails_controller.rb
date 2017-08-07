class ScrapeFailsController < ApplicationController
  before_action :authenticate_admin!

  def index
    @scrape_fails = ScrapeFail.active
    #paginage that shit
  end


  def show
    @scrape_fail = ScrapeFail.find_by_id(params[:id])
  end

  def update
    @scrape_fail = ScrapeFail.find_by_id(params[:id])
    if @scrape_fail.update_attributes(fail_params)
      flash[:success] = "Success!"
      redirect_to scrape_fails_path
    else
      flash[:error] = "Something went wrong."
      redirect_to scrape_fails_path
    end
  end

  private

  def fail_params
    params.require(:scrape_fail).permit(:active)
  end

end
