describe PagesController do
  describe "#home" do
    before do
      get :home
    end

    it { is_expected.to respond_with(:found) }
  end

  describe "#about" do
    before do
      get :about
    end

    it { is_expected.to respond_with(:success) }
  end

  describe "#about_codemarathon" do
    before do
      get :about_codemarathon
    end

    it { is_expected.to respond_with(:success) }
  end
end
