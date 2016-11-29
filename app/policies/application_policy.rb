class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    logger.info "---------------  ApplicationPolicy.initialize  ---------------"

    @user = user
    @record = record
  end

  def index?
    true
    #false
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def create?
    true
    #false
  end

  def new?
    true
    #create?
  end

  def update?
    true
    #false
  end

  def edit?
    update?
  end

  def destroy?
    true
    #false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

end
