import React from 'react';
import './Common.css';
import 'semantic-ui-css/semantic.min.css'
import "react-datepicker/dist/react-datepicker.css"
import DatePicker, { registerLocale } from "react-datepicker"
import ja from 'date-fns/locale/ja';
import addDays from 'date-fns/addDays';
import axios from 'axios';
import format from 'date-fns/format';
import Result from './Result';
import Loading from './Loading';


const Today = new Date();
registerLocale('ja', ja);

class Home extends React.Component {

  // ユーザの動きに合わせて変わる値のことをstate
  state = { date: addDays(new Date(), 14), budget: '12000', departure: '1', duration: '90', plans: null, planCount: 0, error: null, error: false, loading:false }

  onFormSubmit = async (event) => {

    // 例外処理
    try {
      event.preventDefault();
      this.setState({loading: true});
      // throw 'error';  意図的に例外をを起こす
      const response = await axios.get('http://localhost:3000/data', {
        // 第２引数にクエリパラメータをセットできる
        params: { date: format(this.state.date, 'yyyyMMdd'), budget: this.state.budget, departure: this.state.departure, duration: this.state.duration }
      });
      // responseのrequest/responseURL: "http://localhost:3000/data?date=20211012&budget=12000&departure=1&duration=90"

      console.log(response);
      
      // planCount: 0 にしてレスポンスが0だった場合の挙動を確認
      // this.setState({ planCount: 0, plans: response.data.plans })
      this.setState({ planCount: response.data.planCount, plans: response.data.plans })
      // 処理が更新されたらロードをfalseにする
      this.setState({loading: false});
      } catch (e) {
        this.setState({ error: e })
      }    
  }

  render() {
    return(
      <div className="ui container" id="container">
        <div className="Search__Form">
        <form className="ui form segment" onSubmit={this.onFormSubmit}>
            <div className="field">
              <label><i className="calendar alternate outline icon"></i>プレー日</label>
              <DatePicker 
              dataFormat="yyy/MM/dd"
              locale='ja'
              selected={this.state.date}
              onChange={e => this.setState({date: e})}
              minDate={Today}
              />
            </div>
            <div className="field">
              <label><i className="yen sign icon"></i>上限金額</label>
              <select className="ui dropdown" name="dropdown" value={this.state.budget} onChange={e => this.setState({ budget: e.target.value })}>
                <option value="8000">8000円</option>
                <option value="12,000">12,000円</option>
                <option value="16,000">16,000円</option>
              </select>
            </div>
            <div className="field">
              <label className="map pin icon"><i></i>移動時間計算の出発地点（自宅から近い地点をお選びください）</label>
              <select className="ui dropdown" name="dropdown" value={this.state.departure} onChange={e => this.setState({ departure: e.target.value })}>
                <option value="1">東京駅</option>
                <option value="2">横浜駅</option>
              </select>
            </div>
            <div className="field">
              <label className="car icon"><i></i>車での移動時間の上限</label>
              <select className="ui dropdown" name="dropdown" value={this.state.duration} onChange={e => this.setState({ duration: e.target.value })}>
                <option value="60">60分</option>
                <option value="90">90分</option>
                <option value="120">120分</option>
              </select>
            </div>
            <div>
              <button type="submit" className="Search__Button__Design">
                <i className="search icon">ゴルフ場を検索する</i>
              </button>
            </div>
          </form>
          <Loading loading={this.state.loading}/>
          <Result plans={this.state.plans} planCount={this.state.planCount} error={this.state.error}/>
        </div>
      </div>
    )
  }
}

export default Home;