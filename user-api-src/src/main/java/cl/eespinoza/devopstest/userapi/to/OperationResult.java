package cl.eespinoza.devopstest.userapi.to;

public class OperationResult {
  
  private Long result;

  public OperationResult() {
  }

  public OperationResult(Long result) {
    this.result = result;
  }

  public Long getResult() {
    return result;
  }

  public void setResult(Long result) {
    this.result = result;
  }

}
