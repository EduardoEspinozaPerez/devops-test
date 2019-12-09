# DevOps Test

**Author:**
Eduardo Espinoza Pérez (eduardo.espinoza@tenpo.cl)

**Requirements:**
1. packer
2. terraform

**Instructions:**
1. Create Azure empty resource group `eespinoza-devopstest-images` (required by Packer)
2. Give execution permissions to `start.sh` (`chmod +x start.sh`)
3. Set Azure account variables and VMs SSH public key in `start.sh`
4. Run `start.sh` (`./start.sh`)

**Default VMs user:**
testuser

**API default port:**
HTTP 8069

**API definition:**

1. **PUT /devops-test/users**
Add new user.

```json
{
  "identifier": "eespinoza",
  "password": "12345"
}
```
**Returns:**
HTTP 201 (Created)



2. **POST /devops-test/login**
Request login.

```json
{
  "identifier": "eespinoza",
  "password": "12345"
}
```
**Returns:**
```json
{
    "token": "<JWT Token>"
}
```



3. **DELETE /devops-test/logout**
Perform user logout (token revocation).

**Required headers:**
`Authorization: Bearer <JWT Token>`

**Returns:**
```json
{
    "token": "<JWT Token>"
}
```



4. **GET /devops-test/sum/{primaryOperand}/{secondaryOperand}**
Perform addition operation.

```http
GET /devops-test/sum/2/2
```

**Required headers:**
`Authorization: Bearer <JWT Token>`

**Returns:**
```json
{
    "result": 4
}
```



5. **GET /devops-test/history**
Retrieve user's operation history.

**Required headers:**
`Authorization: Bearer <JWT Token>`

**Returns:**
```json
[
  {
    "id": "e004a0fb-53d9-4787-a3c8-fa16ce02d05e",
    "primary_operand": 36,
    "secondary_operand": 88,
    "result": 124,
    "created_at": "2019-12-08T22:50:41.665104Z"
  }
]
```