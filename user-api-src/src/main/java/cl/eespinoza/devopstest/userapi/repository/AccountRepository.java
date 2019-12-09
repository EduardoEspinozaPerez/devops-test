package cl.eespinoza.devopstest.userapi.repository;

import cl.eespinoza.devopstest.userapi.entity.Account;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AccountRepository extends CrudRepository<Account, UUID> {
  
  Optional<Account> findByIdentifier(String identifier);

}
