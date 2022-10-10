class Skedjewel::LockManager
  def with_lock(resource_key, lock_time_in_seconds)
    lock_obtained =
      Skedjewel.app_redis.set(resource_key, "locked", lock_time_in_seconds, nil, true, nil)
    #                 def set(key,          value,    ex,                   px,  nx,   xx)
    yield if lock_obtained
  end
end
