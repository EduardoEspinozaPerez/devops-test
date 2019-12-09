package cl.eespinoza.devopstest.userapi.service;

import cl.eespinoza.devopstest.userapi.repository.AccountRepository;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.JwsHeader;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.MalformedJwtException;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.SignatureException;
import io.jsonwebtoken.SigningKeyResolverAdapter;
import io.jsonwebtoken.UnsupportedJwtException;

import java.util.Date;
import java.util.Optional;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthenticationService {

  private AccountRepository accountRepository;

  @Autowired
  public AuthenticationService(AccountRepository accountRepository) {
    this.accountRepository = accountRepository;
  }
  
  public Optional<String> authenticate(String identifier, String password) {
    var passwordEncoder = new BCryptPasswordEncoder();

    return accountRepository
        .findByIdentifier(identifier)
            .filter(x -> passwordEncoder.matches(password, x.getPassword()))
            .map(x -> {
              var secret = UUID.randomUUID();
              String token = Jwts.builder()
                  .setId(UUID.randomUUID().toString())
                  .setSubject(x.getId().toString())
                  .setExpiration(new Date(System.currentTimeMillis() + 3600000))
                  .signWith(SignatureAlgorithm.HS512, secret.toString().getBytes())
                  .compact();

              x.setSecret(secret);
              accountRepository.save(x);

              return token;
            });
  }

  public boolean isAuthenticated(String authorization) {
    if (authorization == null) {
      return false;
    }

    try {
      extractAccountId(authorization);
      return true;
    } catch (ExpiredJwtException | MalformedJwtException 
        | SignatureException | UnsupportedJwtException | IllegalArgumentException e) {
      return false;
    }
  }

  public void logout(String authorization) {
    var accountId = extractAccountId(authorization);

    accountRepository.findById(accountId).ifPresent(x -> {
      x.setSecret(UUID.randomUUID());
      accountRepository.save(x);
    });
  }

  public UUID extractAccountId(String authorization) {
    var token = cleanToken(authorization);
    var jwt = Jwts.parser().setSigningKeyResolver(new SigningKeyResolverAdapter() {
      @Override
      public byte[] resolveSigningKeyBytes(JwsHeader header, Claims claims) {
        var accountId = UUID.fromString(claims.getSubject());
        byte[] secret = accountRepository.findById(accountId)
          .map(x -> x.getSecret().toString().getBytes()).orElse(null);
        return secret;
      }
    }).parse(token);

    var claims = (Claims) jwt.getBody();
    return UUID.fromString(claims.getSubject());
  }

  private String cleanToken(String authorization) {
    return authorization.replaceAll("Bearer ", "").replaceAll("bearer ", "");
  }

}
