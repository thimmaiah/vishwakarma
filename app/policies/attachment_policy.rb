class AttachmentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.has_cached_role?(:super)
        scope.all
      elsif user.has_cached_role?(:team_lead) || user.has_cached_role?(:team_member)
        scope.where(company_id: user.company_id)
      else
        scope.joins(project: :project_accesses).visible_to_client
             .where("project_accesses.user_id=? and project_accesses.role_name in (?)", user.id, ["Client"])
      end
    end
  end

  def index?
    true
  end

  def dashboard?
    true
  end

  def search?
    true
  end

  def show?
    if user.has_cached_role?(:super) || user.company_id == record.company_id
      true
    else
      Step.joins(project: :project_accesses).visible_to_client
          .where("project_accesses.user_id=?", user.id)
          .where(id: record.id).present?
    end
  end

  def create?
    user.has_cached_role?(:team_member) && user.company_id == record.company_id
  end

  def new?
    create?
  end

  def toggle_approval?
    user.has_cached_role?(:team_lead) && user.company_id == record.company_id
  end

  def update?
    create? && (record.attached_by_id == user.id || user.has_cached_role?(:team_lead))
  end

  def edit?
    update?
  end

  def destroy?
    update?
  end

  def toggle_completed?
    update?
  end
end