package cl.eespinoza.devopstest.userapi.controller;

import cl.eespinoza.devopstest.userapi.entity.Account;
import cl.eespinoza.devopstest.userapi.entity.History;
import cl.eespinoza.devopstest.userapi.entity.OperationType;
import cl.eespinoza.devopstest.userapi.repository.AccountRepository;
import cl.eespinoza.devopstest.userapi.service.AuthenticationService;
import cl.eespinoza.devopstest.userapi.to.Credentials;
import cl.eespinoza.devopstest.userapi.to.OperationResult;
import cl.eespinoza.devopstest.userapi.to.TokenResponse;

import java.util.List;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/devops-test")
public class ApiController {

  private static final Logger log = LoggerFactory.getLogger(ApiController.class);

  private AccountRepository accountRepository;
  private AuthenticationService authenticationService;

  /**
   * Autowired constructor.
   * 
   * @param userRepository Users JPA repository.
   * @param authenticationService Authentication service.
   */
  @Autowired
  public ApiController(AccountRepository userRepository, 
      AuthenticationService authenticationService) {
    this.accountRepository = userRepository;
    this.authenticationService = authenticationService;
  }

  /**
   * Perform a user register.
   * 
   * @param user User payload.
   * @return Created user.
   */
  @PutMapping("/users")
  public ResponseEntity<Account> addUser(@RequestBody Account user) {
    BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
    user.setPassword(passwordEncoder.encode(user.getPassword()));

    return ResponseEntity.status(HttpStatus.CREATED).body(accountRepository.save(user));
  }

  /**
   * Perform user login.
   * 
   * @param credentials User credentials.
   * @return Access token.
   */
  @PostMapping("/login")
  public ResponseEntity<TokenResponse> login(@RequestBody Credentials credentials) {
    return authenticationService.authenticate(credentials.getIdentifier(),
        credentials.getPassword())
        .map(x -> ResponseEntity.ok().body(new TokenResponse(x)))
        .orElseGet(() -> ResponseEntity.status(HttpStatus.FORBIDDEN).build());
  }

  /**
   * Perform user logout.
   * 
   * @param authorization Authorization header.
   * @return 
   */
  @DeleteMapping("/logout")
  public ResponseEntity<?> logout(@RequestHeader("Authorization")
      String authorization) {
    authenticationService.logout(authorization);
    return ResponseEntity.ok().build();
  }

  /**
   * Display user operations history.
   * 
   * @param authorization Authorization header.
   */
  @GetMapping("/history")
  public ResponseEntity<List<History>> listHistory(
      @RequestHeader(name = "Authorization", required = false) String authorization) {
    if (!authenticationService.isAuthenticated(authorization)) {
      return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
    }

    var accountId = authenticationService.extractAccountId(authorization);

    return accountRepository.findById(accountId)
        .map(x -> ResponseEntity.ok().body(x.getHistories()))
        .orElseGet(() -> ResponseEntity.noContent().build());
  }
  
  /**
   * Perform an addition operation.
   * 
   * @param authorization Authorization header.
   * @param primaryOperand Primary operand.
   * @param secondaryOperand Secondary operand.
   * @return Operation result.
   */
  @GetMapping("/sum/{primaryOperand}/{secondaryOperand}")
  public ResponseEntity<OperationResult> 
      addition(@RequestHeader(name = "Authorization", required = false)
      String authorization, @PathVariable("primaryOperand") Long primaryOperand, 
      @PathVariable("secondaryOperand") Long secondaryOperand) {

    if (!authenticationService.isAuthenticated(authorization)) {
      return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
    }

    if (primaryOperand == null || secondaryOperand == null) {
      return ResponseEntity.badRequest().build();
    }

    var accountId = authenticationService.extractAccountId(authorization);
    var operationResult = new OperationResult(primaryOperand + secondaryOperand);

    accountRepository.findById(accountId).ifPresentOrElse(x -> {
      x.getHistories().add(new History(OperationType.Addition,
          primaryOperand, secondaryOperand, operationResult.getResult()));
      accountRepository.save(x);
    }, () -> log.warn("[sum] Cannot register operation. User not found"));

    return ResponseEntity.ok().body(operationResult);
  }
}
