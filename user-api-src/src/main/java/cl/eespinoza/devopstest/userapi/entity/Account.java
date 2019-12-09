package cl.eespinoza.devopstest.userapi.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonProperty.Access;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.OneToMany;
import javax.persistence.PrePersist;
import javax.persistence.PreUpdate;

@Entity
public class Account {
  
  @Id
  @Column(updatable = false)
  @JsonProperty(access = Access.READ_ONLY, required = false)
  private UUID id;

  @JsonProperty(required = true)
  private String identifier;

  @JsonProperty(access = Access.WRITE_ONLY)
  private String password;

  @JsonIgnore
  private UUID secret;

  @JsonProperty(access = Access.READ_ONLY, required = false)
  private OffsetDateTime createdAt;

  @JsonProperty(access = Access.READ_ONLY, required = false)
  private OffsetDateTime updatedAt;

  @OneToMany(cascade = CascadeType.ALL)
  @JsonIgnore
  private List<History> histories;

  @PrePersist
  private void prePersist() {
    this.id = UUID.randomUUID();
    this.createdAt = OffsetDateTime.now();
    this.updatedAt = OffsetDateTime.now();
  }

  @PreUpdate
  private void preUpdate() {
    this.updatedAt = OffsetDateTime.now();
  }

  public UUID getId() {
    return id;
  }

  public void setId(UUID id) {
    this.id = id;
  }

  public String getIdentifier() {
    return identifier;
  }

  public void setIdentifier(String identifier) {
    this.identifier = identifier;
  }

  public String getPassword() {
    return password;
  }

  public void setPassword(String password) {
    this.password = password;
  }

  public OffsetDateTime getCreatedAt() {
    return createdAt;
  }

  public void setCreatedAt(OffsetDateTime createdAt) {
    this.createdAt = createdAt;
  }

  public OffsetDateTime getUpdatedAt() {
    return updatedAt;
  }

  public void setUpdatedAt(OffsetDateTime updatedAt) {
    this.updatedAt = updatedAt;
  }

  public List<History> getHistories() {
    return histories;
  }

  public void setHistories(List<History> histories) {
    this.histories = histories;
  }

  public UUID getSecret() {
    return secret;
  }

  public void setSecret(UUID secret) {
    this.secret = secret;
  }

}
