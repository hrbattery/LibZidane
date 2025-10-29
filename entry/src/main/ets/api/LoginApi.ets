import ReqInst from "../common/request/Request"
import { LogUtil as logger } from "@pura/harmony-utils"

interface LoginData {
  email: string,
  password: string
}

interface UserInfoResponse {
  id: number,
  remix_userkey: string,
  downloads_limit: number,
  downloads_today: number,
  email: string,
  name: string
}

interface LoginResponse {
  success: number,
  user: UserInfoResponse
}

/*
 * todo:
 * /eapi/user/token-sign-in (POST); body parameters: name, id_token
 * */

export async function login(email: string, password: string): Promise<boolean> {
  let response = await ReqInst.post<LoginResponse, LoginData>("/eapi/user/login", { email, password })
  logger.debug(response)
  if (response.success === 1) {
    // todo: 记录userkey和userid，是不是可以直接用cookie存着
    return true;
  }
  return false;
}