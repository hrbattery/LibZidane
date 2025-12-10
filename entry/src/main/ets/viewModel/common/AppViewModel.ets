import { PersistenceV2 } from '@kit.ArkUI';
import { AppState } from '../../model/entities/AppState';

@ObservedV2
export class AppViewModel {
  @Trace appState: AppState = PersistenceV2.connect(AppState, 'appState', () => new AppState())!
}