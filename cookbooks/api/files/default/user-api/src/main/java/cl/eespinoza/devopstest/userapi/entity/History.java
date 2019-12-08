package cl.eespinoza.devopstest.userapi.entity;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonProperty.Access;

import java.time.OffsetDateTime;
import java.util.UUID;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.Id;
import javax.persistence.PrePersist;

@Entity
public class History {
  
  @Id
  @Column(updatable = false)
  @JsonProperty(access = Access.READ_ONLY)
  private UUID id;

  @JsonProperty(access = Access.READ_ONLY)
  private Long primaryOperand;

  @JsonProperty(access = Access.READ_ONLY)
  private Long secondaryOperand;

  @JsonProperty(access = Access.READ_ONLY)
  private Long result;

  @Enumerated(EnumType.STRING)
  @JsonProperty(access = Access.READ_ONLY)
  private OperationType operationType;

  @JsonProperty(access = Access.READ_ONLY)
  private OffsetDateTime createdAt;

  @PrePersist
  private void prePersist() {
    this.id = UUID.randomUUID();
    this.createdAt = OffsetDateTime.now();
  }

  public History() {
  }

  /**
   * Constructs a new operation history entry.
   * 
   * @param operationType Operation type.
   * @param primaryOperand Primary operand.
   * @param secondaryOperand Secondary operand.
   * @param result Operation result.
   */
  public History(OperationType operationType, Long primaryOperand,
      Long secondaryOperand, Long result) {
    this.primaryOperand = primaryOperand;
    this.secondaryOperand = secondaryOperand;
    this.result = result;
  }

  public UUID getId() {
    return id;
  }

  public void setId(UUID id) {
    this.id = id;
  }

  public Long getPrimaryOperand() {
    return primaryOperand;
  }

  public void setPrimaryOperand(Long primaryOperand) {
    this.primaryOperand = primaryOperand;
  }

  public Long getSecondaryOperand() {
    return secondaryOperand;
  }

  public void setSecondaryOperand(Long secondaryOperand) {
    this.secondaryOperand = secondaryOperand;
  }

  public Long getResult() {
    return result;
  }

  public void setResult(Long result) {
    this.result = result;
  }

  public OffsetDateTime getCreatedAt() {
    return createdAt;
  }

  public void setCreatedAt(OffsetDateTime createdAt) {
    this.createdAt = createdAt;
  }

}
