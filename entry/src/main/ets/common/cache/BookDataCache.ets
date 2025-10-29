import { FullBookDataType } from "../../models/BookModel";
import { CacheManager } from "./CacheManager";

export const bookDataCache = new CacheManager<FullBookDataType>("bookDataCache")