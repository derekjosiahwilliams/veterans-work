require 'rails_helper'

RSpec.describe "the signin process", :type => :feature do
  before :each do
   create :company, email: 'user@example.com', password: 'password', status: 'Active'
  end

  it "signs me in" do
    visit '/companies/sign_in'
    within(".login-form") do
      fill_in 'company[email]', with: 'user@example.com'
      fill_in 'company[password]', with: 'password'
    end
    click_button 'Log in'
    expect(page).to have_content 'Signed in successfully'
  end
end

RSpec.describe "the signout process", :type => :feature do
  before :each do
    @company = create :company, email: 'company@example.com', password: 'password', status: 'Active'
    visit '/companies/sign_in'
    within(".login-form") do
      fill_in 'company[email]', with: 'company@example.com'
      fill_in 'company[password]', with: 'password'
    end
    click_button 'Log in'
  end

  it 'signs me out' do
    visit '/customer_requests'
    find(:css, 'ul.nav.navbar-nav.navbar-right').click_on("Logout #{@company.name}")
    expect(page).to have_content 'Signed out successfully'
  end
end


RSpec.describe 'company creates quote', :type => :feature do
  before :each do
    @company = create :company, email: 'user@example.com', password: 'password', status: 'Active', service_radius: 30.0, latitude: 41.9687556, longitude: -87.6939721
    @service_category = create :service_category, name: 'Paint'
    @company_service = create :company_service, service_category_id: @service_category.id, company_id: @company.id
    @customer = create :customer, email: 'customer@example.com', password: 'password'
    @customer_request = create :customer_request, customer_id: @customer.id, service_category_id: @service_category.id, zipcode: '60601', expires_date: Date.today() + 3, latitude: 41.9687556, longitude: -87.6939721
    visit '/companies/sign_in'
    within(".login-form") do
      fill_in 'company[email]', with: 'user@example.com'
      fill_in 'company[password]', with: 'password'
    end
    click_button 'Log in'
  end

  it 'company creates quote' do
    expect(page).to have_content 'Signed in successfully.'
    find('td:first-child').click_link
    click_link 'New Quote'
    fill_in 'quote[materials_cost_estimate]', with: '100'
    fill_in 'quote[labor_cost_estimate]', with: '100'
    fill_in 'quote[start_date]', with: Date.today()
    fill_in 'quote[completion_date_estimate]', with: Date.today() + 2
    fill_in 'quote[notes]', with: 'How about them apples!'
    click_button 'Submit'
    expect(page).to have_content 'New Quote created successfully!'
  end
end

RSpec.describe "customer decides on quote", :type => :feature do
  before :each do
    @company1 = create :company, email: 'user1@example.com', password: 'password', status: 'Active', service_radius: 30.0, latitude: 41.9687556, longitude: -87.6939721
    @company2 = create :company, email: 'user2@example.com', password: 'password', status: 'Active', service_radius: 30.0, latitude: 41.9687556, longitude: -87.6939721    
    @service_category = create :service_category, name: 'Paint'
    @customer = create :customer, email: 'customer@example.com', password: 'password'
    @customer_request = create :customer_request, customer_id: @customer.id, description: 'Sample request description', service_category_id: @service_category.id, zipcode: '60601', expires_date: Date.today() + 3, latitude: 41.9687556, longitude: -87.6939721
    @quote1 = create :quote, customer_request_id: @customer_request.id, company_id: @company1.id
    @quote2 = create :quote, customer_request_id: @customer_request.id, company_id: @company2.id
    visit '/companies/sign_in'
    within(".login-form") do
      fill_in 'company[email]', with: 'user1@example.com'
      fill_in 'company[password]', with: 'password'
    end
    click_button 'Log in'
  end

  context 'company view of quotes table for open quotes' do
    before :each do
      visit('/quotes')
    end

    it 'should show open quotes in open quote table' do
      within '#open_quotes' do
        expect(page).to have_content('Sample request description')
      end
    end
    it 'should not show open quotes in accepted quote table' do
      within '#accepted_quotes' do
        expect(page).to_not have_content('Sample request description')
      end
    end
  end

  context 'company view of quotes table when own quote is accepted' do
    before :each do
      @quote1.update(accepted: true)
      @quote2.update(accepted: false)
      visit('/quotes')
    end

    it 'should not show own accepted quotes in open quote table' do
      within '#open_quotes' do
        expect(page).to_not have_content('Sample request description')
      end
    end
    it 'should show own accepted quotes in accepted quote table' do
      within '#accepted_quotes' do
        expect(page).to have_content('Sample request description')
      end
    end
  end

  context 'company view of quotes table when own quote is rejected' do
    before :each do
      @quote2.update(accepted: true)
      @quote1.update(accepted: false)
      visit('/quotes')
    end

    it 'should not show own rejected quotes in open quote table' do
      within '#open_quotes' do
        expect(page).to_not have_content('Sample request description')
      end
    end
    it 'should not show own rejected quotes in accepted quote table' do
      within '#accepted_quotes' do
        expect(page).to_not have_content('Sample request description')
      end
    end
  end
end
